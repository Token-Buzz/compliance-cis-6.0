# CIS 4.4: verify S3 server access logging on the CloudTrail bucket.
# mock_provider avoids real AWS calls; data sources return synthetic values.
mock_provider "aws" {}

run "access_logging_enabled_by_default" {
  command = plan

  variables {
    trail_name      = "org-cloudtrail"
    log_bucket_name = "org-cloudtrail"
    # Skip the CloudWatch Logs role: mock_provider returns an empty JSON object
    # for aws_iam_policy_document, which the IAM role rejects. CWL delivery is
    # orthogonal to the CIS 4.4 access-logging behaviour under test here.
    deliver_to_cloudwatch_logs = false
  }

  assert {
    condition     = length(aws_s3_bucket.access_logs) == 1
    error_message = "Expected the dedicated access-logs target bucket to be planned by default."
  }

  assert {
    condition     = length(aws_s3_bucket_logging.this) == 1
    error_message = "Expected server access logging to be configured on the CloudTrail bucket by default."
  }

  assert {
    condition     = length(aws_s3_bucket_policy.access_logs) == 1
    error_message = "Expected the access-logs target bucket to have a delivery + TLS policy."
  }
}

# Regression: the PRIMARY trail passes an empty log_bucket_name so that
# aws_s3_bucket.this gets an AWS-generated name. The access-logs bucket name and
# the server-access-logging target_prefix must be derived from the REAL bucket
# (aws_s3_bucket.this.id), NOT from var.log_bucket_name — otherwise they collapse
# to the invalid "-access-logs" name / bare "/" prefix and the apply fails with
# "lookup -access-logs.s3.amazonaws.com: no such host".
#
# We assert the plan SUCCEEDS and the resources are still planned. The computed
# bucket name / prefix can't be string-asserted here: aws_s3_bucket.this.id is
# "(known after apply)" under mock_provider, so its value is unknown at plan time.
run "access_logging_with_autonamed_trail_bucket" {
  command = plan

  variables {
    trail_name = "org-cloudtrail"
    # Empty name -> S3 auto-naming for aws_s3_bucket.this (the primary-trail case).
    log_bucket_name            = ""
    deliver_to_cloudwatch_logs = false
  }

  assert {
    condition     = length(aws_s3_bucket.access_logs) == 1
    error_message = "Expected the access-logs target bucket to be planned even when log_bucket_name is empty (auto-named trail bucket)."
  }

  assert {
    condition     = length(aws_s3_bucket_logging.this) == 1
    error_message = "Expected server access logging to be configured even when log_bucket_name is empty (auto-named trail bucket)."
  }
}

run "access_logging_can_be_disabled" {
  command = plan

  variables {
    trail_name                 = "org-cloudtrail"
    log_bucket_name            = "org-cloudtrail"
    enable_access_logging      = false
    deliver_to_cloudwatch_logs = false
  }

  assert {
    condition     = length(aws_s3_bucket.access_logs) == 0
    error_message = "Expected no access-logs bucket when enable_access_logging = false."
  }

  assert {
    condition     = length(aws_s3_bucket_logging.this) == 0
    error_message = "Expected no server access logging when enable_access_logging = false."
  }
}
