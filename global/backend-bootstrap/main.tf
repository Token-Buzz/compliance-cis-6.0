# Backend bootstrap (chicken-and-egg).
#
# This root intentionally uses LOCAL state — it creates the very S3 bucket and
# DynamoDB lock table that every OTHER root will use as their remote backend.
# It must be applied FIRST, before any other root can `terraform init` against
# the S3 backend. After this is applied, other roots configure:
#
#   terraform {
#     backend "s3" {
#       bucket         = "<state_bucket_name>"
#       key            = "<root>/terraform.tfstate"
#       region         = "<region>"
#       use_lockfile   = true
#       encrypt        = true
#     }
#   }
#
# Keep this root minimal: it is excluded from policy scans (see .checkov.yaml)
# because it deliberately holds local state and the security guardrails that
# checkov enforces elsewhere are bootstrapped by the org-foundation roots.

# ---------------------------------------------------------------------------
# S3 bucket holding remote state
# ---------------------------------------------------------------------------
resource "aws_s3_bucket" "state" {
  bucket = var.state_bucket_name
  tags   = var.tags
}

resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = aws_s3_bucket.state.id

  rule {
    apply_server_side_encryption_by_default {
      # Use the AWS-managed aws/s3 KMS key: encryption at rest without the
      # operational burden of managing a customer-managed CMK for the bootstrap.
      sse_algorithm = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "state" {
  bucket = aws_s3_bucket.state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "state" {
  bucket = aws_s3_bucket.state.id

  rule {
    id     = "expire-noncurrent-state-versions"
    status = "Enabled"

    # Required by AWS provider v5: an empty filter targets all objects.
    filter {}

    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
}

# TLS-only: deny any request that is not made over HTTPS.
data "aws_iam_policy_document" "state_tls_only" {
  statement {
    sid    = "DenyInsecureTransport"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = ["s3:*"]

    resources = [
      aws_s3_bucket.state.arn,
      "${aws_s3_bucket.state.arn}/*",
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "state" {
  bucket = aws_s3_bucket.state.id
  policy = data.aws_iam_policy_document.state_tls_only.json

  # The public access block must exist first so attaching a bucket policy
  # cannot transiently expose the bucket.
  depends_on = [aws_s3_bucket_public_access_block.state]
}
