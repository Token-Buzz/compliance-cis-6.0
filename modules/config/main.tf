data "aws_partition" "current" {}

locals {
  create_role = var.iam_role_arn == null
  role_arn    = coalesce(var.iam_role_arn, try(aws_iam_role.config[0].arn, null))
}

data "aws_iam_policy_document" "assume" {
  count = local.create_role ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "config" {
  count = local.create_role ? 1 : 0

  name_prefix        = "config-recorder-"
  assume_role_policy = data.aws_iam_policy_document.assume[0].json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "config" {
  count = local.create_role ? 1 : 0

  role       = aws_iam_role.config[0].name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWS_ConfigRole"
}

resource "aws_config_configuration_recorder" "this" {
  name     = "default"
  role_arn = local.role_arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = var.include_global_resource_types
  }
}

resource "aws_config_delivery_channel" "this" {
  name           = "default"
  s3_bucket_name = var.s3_bucket_name
  s3_key_prefix  = var.s3_key_prefix
  sns_topic_arn  = var.sns_topic_arn

  depends_on = [aws_config_configuration_recorder.this]
}

resource "aws_config_configuration_recorder_status" "this" {
  name       = aws_config_configuration_recorder.this.name
  is_enabled = true

  depends_on = [aws_config_delivery_channel.this]
}

resource "aws_config_configuration_aggregator" "org" {
  count = var.enable_organization_aggregator ? 1 : 0

  name = var.aggregator_name

  organization_aggregation_source {
    all_regions = true
    role_arn    = var.aggregator_role_arn
  }

  tags = var.tags

  lifecycle {
    precondition {
      condition     = var.aggregator_role_arn != null
      error_message = "aggregator_role_arn is required when enable_organization_aggregator is true."
    }
  }
}
