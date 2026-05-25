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
