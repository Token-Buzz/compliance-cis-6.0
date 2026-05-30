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
