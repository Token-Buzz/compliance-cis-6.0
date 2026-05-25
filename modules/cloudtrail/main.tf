data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_region" "current" {}

locals {
  account_id  = data.aws_caller_identity.current.account_id
  partition   = data.aws_partition.current.partition
  region      = data.aws_region.current.name
  kms_key_arn = var.create_kms_key ? aws_kms_key.this[0].arn : var.kms_key_arn
  create_kms  = var.create_kms_key
  trail_arn   = "arn:${local.partition}:cloudtrail:${local.region}:${local.account_id}:trail/${var.trail_name}"
}

# Dedicated CMK for trail + CloudWatch Logs encryption when the caller does not supply one.
data "aws_iam_policy_document" "kms" {
  count = local.create_kms ? 1 : 0

  statement {
    sid       = "EnableRootPermissions"
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:${local.partition}:iam::${local.account_id}:root"]
    }
  }

  statement {
    sid       = "AllowCloudTrailEncrypt"
    effect    = "Allow"
    actions   = ["kms:GenerateDataKey*"]
    resources = ["*"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values   = ["arn:${local.partition}:cloudtrail:*:${local.account_id}:trail/*"]
    }
  }

  statement {
    sid       = "AllowCloudTrailDescribeKey"
    effect    = "Allow"
    actions   = ["kms:DescribeKey"]
    resources = ["*"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }

  statement {
    sid    = "AllowCloudWatchLogsUse"
    effect = "Allow"
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*",
    ]
    resources = ["*"]

    principals {
      type        = "Service"
      identifiers = ["logs.${local.region}.amazonaws.com"]
    }

    condition {
      test     = "ArnLike"
      variable = "kms:EncryptionContext:aws:logs:arn"
      values   = ["arn:${local.partition}:logs:${local.region}:${local.account_id}:log-group:*"]
    }
  }
}

resource "aws_kms_key" "this" {
  count = local.create_kms ? 1 : 0

  description             = "CMK for ${var.trail_name} CloudTrail and CloudWatch Logs"
  enable_key_rotation     = true
  deletion_window_in_days = 30
  policy                  = data.aws_iam_policy_document.kms[0].json

  tags = var.tags
}

resource "aws_kms_alias" "this" {
  count = local.create_kms ? 1 : 0

  name          = "alias/${var.trail_name}-cloudtrail"
  target_key_id = aws_kms_key.this[0].key_id
}

resource "aws_s3_bucket" "this" {
  bucket = var.log_bucket_name

  tags = var.tags
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = local.kms_key_arn != null ? "aws:kms" : "AES256"
      kms_master_key_id = local.kms_key_arn
    }
    bucket_key_enabled = local.kms_key_arn != null
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    id     = "expire-trail-logs"
    status = "Enabled"

    filter {}

    expiration {
      days = var.s3_log_retention_days
    }
  }
}

data "aws_iam_policy_document" "bucket" {
  statement {
    sid       = "AWSCloudTrailAclCheck"
    effect    = "Allow"
    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.this.arn]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [local.trail_arn]
    }
  }

  statement {
    sid       = "AWSCloudTrailWrite"
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.this.arn}/AWSLogs/${local.account_id}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [local.trail_arn]
    }
  }

  # Organization trails also write under the org-wide prefix.
  dynamic "statement" {
    for_each = var.is_organization_trail ? [1] : []

    content {
      sid       = "AWSCloudTrailWriteOrg"
      effect    = "Allow"
      actions   = ["s3:PutObject"]
      resources = ["${aws_s3_bucket.this.arn}/AWSLogs/*"]

      principals {
        type        = "Service"
        identifiers = ["cloudtrail.amazonaws.com"]
      }

      condition {
        test     = "StringEquals"
        variable = "s3:x-amz-acl"
        values   = ["bucket-owner-full-control"]
      }

      condition {
        test     = "StringEquals"
        variable = "aws:SourceArn"
        values   = [local.trail_arn]
      }
    }
  }

  statement {
    sid       = "DenyInsecureTransport"
    effect    = "Deny"
    actions   = ["s3:*"]
    resources = [aws_s3_bucket.this.arn, "${aws_s3_bucket.this.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.bucket.json

  depends_on = [aws_s3_bucket_public_access_block.this]
}

resource "aws_cloudwatch_log_group" "this" {
  count = var.deliver_to_cloudwatch_logs ? 1 : 0

  name              = "/aws/cloudtrail/${var.trail_name}"
  retention_in_days = var.cloudwatch_logs_retention_days
  kms_key_id        = local.create_kms ? local.kms_key_arn : null

  tags = var.tags
}

data "aws_iam_policy_document" "cwl_assume" {
  count = var.deliver_to_cloudwatch_logs ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "cwl" {
  count = var.deliver_to_cloudwatch_logs ? 1 : 0

  name               = "${var.trail_name}-cloudtrail-cwl"
  assume_role_policy = data.aws_iam_policy_document.cwl_assume[0].json

  tags = var.tags
}

data "aws_iam_policy_document" "cwl" {
  count = var.deliver_to_cloudwatch_logs ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["${aws_cloudwatch_log_group.this[0].arn}:*"]
  }
}

resource "aws_iam_role_policy" "cwl" {
  count = var.deliver_to_cloudwatch_logs ? 1 : 0

  name   = "${var.trail_name}-cloudtrail-cwl"
  role   = aws_iam_role.cwl[0].id
  policy = data.aws_iam_policy_document.cwl[0].json
}

resource "aws_cloudtrail" "this" {
  name                          = var.trail_name
  s3_bucket_name                = aws_s3_bucket.this.id
  is_multi_region_trail         = true
  include_global_service_events = true
  enable_log_file_validation    = true
  enable_logging                = true
  kms_key_id                    = local.kms_key_arn
  is_organization_trail         = var.is_organization_trail
  cloud_watch_logs_group_arn    = var.deliver_to_cloudwatch_logs ? "${aws_cloudwatch_log_group.this[0].arn}:*" : null
  cloud_watch_logs_role_arn     = var.deliver_to_cloudwatch_logs ? aws_iam_role.cwl[0].arn : null

  advanced_event_selector {
    name = "Management events"

    field_selector {
      field  = "eventCategory"
      equals = ["Management"]
    }
  }

  dynamic "advanced_event_selector" {
    for_each = var.s3_data_event_write_all_buckets ? [1] : []

    content {
      name = "S3 write data events"

      field_selector {
        field  = "eventCategory"
        equals = ["Data"]
      }

      field_selector {
        field  = "resources.type"
        equals = ["AWS::S3::Object"]
      }

      field_selector {
        field  = "readOnly"
        equals = ["false"]
      }
    }
  }

  dynamic "advanced_event_selector" {
    for_each = length(var.s3_read_event_bucket_arns) > 0 ? [1] : []

    content {
      name = "S3 read data events (scoped)"

      field_selector {
        field  = "eventCategory"
        equals = ["Data"]
      }

      field_selector {
        field  = "resources.type"
        equals = ["AWS::S3::Object"]
      }

      field_selector {
        field  = "readOnly"
        equals = ["true"]
      }

      field_selector {
        field       = "resources.ARN"
        starts_with = var.s3_read_event_bucket_arns
      }
    }
  }

  dynamic "advanced_event_selector" {
    for_each = var.enable_lambda_data_events ? [1] : []

    content {
      name = "Lambda data events"

      field_selector {
        field  = "eventCategory"
        equals = ["Data"]
      }

      field_selector {
        field  = "resources.type"
        equals = ["AWS::Lambda::Function"]
      }
    }
  }

  tags = var.tags

  depends_on = [aws_s3_bucket_policy.this]
}
