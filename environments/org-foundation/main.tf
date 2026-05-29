# Home-region (us-east-1, default provider) account-wide guardrails. These are
# global/account-scoped and run exactly once.

module "iam_baseline" {
  source = "../../modules/iam-baseline"

  manage_password_policy                = true
  enable_account_s3_block_public_access = true

  primary_contact  = var.primary_contact
  security_contact = var.security_contact

  create_support_role = true

  tags = var.tags
}

module "cloudtrail" {
  source = "../../modules/cloudtrail"

  trail_name            = var.trail_name
  log_bucket_name       = var.trail_log_bucket_name
  is_organization_trail = var.is_organization_trail

  # Cost-minimized: free SSE-S3 encryption (no KMS key) and no CloudWatch Logs
  # delivery. CIS monitoring is handled by the EventBridge rules below.
  create_kms_key             = false
  deliver_to_cloudwatch_logs = false

  s3_data_event_write_all_buckets = true
  s3_read_event_bucket_arns       = var.s3_read_event_bucket_arns

  tags = var.tags
}

module "monitoring_events" {
  source = "../../modules/monitoring-events"

  notification_email = var.alarm_email

  tags = var.tags
}

# ── OPT-IN: CIS §5 CloudWatch metric-filter alarms (5.1–5.14) ──────────────
#
# WHY a second, dedicated trail:
#   The primary trail above captures ALL S3 write data events for every bucket
#   (s3_data_event_write_all_buckets = true). Enabling CloudWatch Logs delivery
#   on that trail would ingest those data events at $0.50/GB, erasing the
#   near-$0 posture. This separate trail records management events ONLY
#   (s3_data_event_write_all_buckets = false, s3_read_event_bucket_arns = []),
#   so CloudWatch Logs ingestion stays tiny and predictable (~$2–3/mo total).
#
# The EventBridge→SNS rules in module.monitoring_events are NOT removed; they
# remain the always-on, free compensating control. These alarms are additive.

# Enforce the cross-variable constraint that monitoring_trail_log_bucket_name
# must be provided whenever enable_cloudwatch_alarms is true.
# (Terraform variable validation blocks cannot reference other variables, so
# this lives here as a check block instead.)
check "monitoring_bucket_name_required" {
  assert {
    condition     = var.enable_cloudwatch_alarms ? var.monitoring_trail_log_bucket_name != null : true
    error_message = "monitoring_trail_log_bucket_name must be set when enable_cloudwatch_alarms = true."
  }
}

module "cloudtrail_monitoring" {
  source = "../../modules/cloudtrail"
  count  = var.enable_cloudwatch_alarms ? 1 : 0

  trail_name            = "${var.trail_name}-monitoring"
  log_bucket_name       = var.monitoring_trail_log_bucket_name
  is_organization_trail = var.is_organization_trail

  create_kms_key             = false
  deliver_to_cloudwatch_logs = true

  # Management events ONLY — keeps CloudWatch Logs ingestion small and
  # avoids the high-volume S3 data events from the primary trail.
  s3_data_event_write_all_buckets = false
  s3_read_event_bucket_arns       = []

  tags = var.tags
}

module "cloudwatch_metric_alarms" {
  source = "../../modules/cloudwatch-metric-alarms"
  count  = var.enable_cloudwatch_alarms ? 1 : 0

  log_group_name = module.cloudtrail_monitoring[0].cloudwatch_log_group_name
  sns_topic_arn  = module.monitoring_events.sns_topic_arn

  tags = var.tags
}
