data "aws_vpc" "default" {
  count = var.restrict_default_security_group && var.default_vpc_id == null ? 1 : 0

  default = true
}

locals {
  default_vpc_id = coalesce(var.default_vpc_id, try(data.aws_vpc.default[0].id, null))
}

resource "aws_ebs_encryption_by_default" "this" {
  count = var.enable_ebs_default_encryption ? 1 : 0

  enabled = true
}

resource "aws_ebs_default_kms_key" "this" {
  count = var.ebs_default_kms_key_arn != null ? 1 : 0

  key_arn = var.ebs_default_kms_key_arn
}

# No ingress/egress blocks revokes all rules on the default SG (CIS).
resource "aws_default_security_group" "this" {
  count = var.restrict_default_security_group && local.default_vpc_id != null ? 1 : 0

  vpc_id = local.default_vpc_id

  tags = var.tags
}

resource "aws_flow_log" "this" {
  count = var.enable_flow_logs ? 1 : 0

  log_destination_type = "s3"
  log_destination      = var.flow_logs_s3_destination_arn
  traffic_type         = var.flow_logs_traffic_type
  vpc_id               = local.default_vpc_id

  tags = var.tags

  lifecycle {
    precondition {
      condition     = var.flow_logs_s3_destination_arn != null
      error_message = "flow_logs_s3_destination_arn is required when enable_flow_logs is true."
    }
  }
}
