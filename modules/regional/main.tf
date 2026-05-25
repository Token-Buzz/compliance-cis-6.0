# Per-region composition of the CIS guardrails. The root passes exactly one
# regional aws provider as this module's default provider; every child module
# below therefore deploys into that single region.

module "access_analyzer" {
  source = "../access-analyzer"
  count  = var.enable_access_analyzer ? 1 : 0

  analyzer_name = "${var.name_prefix}-${var.region_name}"
  analyzer_type = var.analyzer_type

  tags = var.tags
}

module "config" {
  source = "../config"
  count  = var.enable_config ? 1 : 0

  s3_bucket_name = var.config_s3_bucket_name
  iam_role_arn   = var.config_iam_role_arn

  # Global resource types are recorded only in the home region to avoid
  # duplicate recording across regions.
  include_global_resource_types = var.is_home_region

  # The organization aggregator is regional state; create it only at home.
  enable_organization_aggregator = var.is_home_region
  aggregator_role_arn            = var.config_aggregator_role_arn

  tags = var.tags
}

module "security_hub" {
  source = "../security-hub"
  count  = var.enable_security_hub ? 1 : 0

  # The cross-region finding aggregator is created only in the home region.
  create_finding_aggregator = var.is_home_region

  tags = var.tags
}

module "guardduty" {
  source = "../guardduty"

  enable = var.enable_guardduty

  tags = var.tags
}

module "vpc_baseline" {
  source = "../vpc-baseline"

  restrict_default_security_group = var.restrict_default_security_group
  enable_ebs_default_encryption   = var.enable_ebs_default_encryption

  tags = var.tags
}

# When Config is enabled the caller MUST supply the shared delivery bucket and
# recorder role; both are global resources created once in the root. They are
# optional (null) only because Config can be disabled entirely.
check "config_inputs" {
  assert {
    condition     = !var.enable_config || (var.config_s3_bucket_name != null && var.config_iam_role_arn != null)
    error_message = "enable_config = true requires both config_s3_bucket_name and config_iam_role_arn to be set."
  }
}
