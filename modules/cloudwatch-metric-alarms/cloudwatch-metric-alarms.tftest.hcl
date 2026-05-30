provider "aws" {
  region = "us-east-1"
}

run "creates_full_cis_metric_filter_and_alarm_set" {
  command = plan

  variables {
    log_group_name = "/aws/cloudtrail/test"
    sns_topic_arn  = "arn:aws:sns:us-east-1:123456789012:test"
  }

  assert {
    condition     = length(aws_cloudwatch_log_metric_filter.this) >= 15
    error_message = "Expected the full CIS section 5 metric-filter set (>= 15 filters, 5.1-5.15)."
  }

  assert {
    condition     = length(aws_cloudwatch_metric_alarm.this) >= 15
    error_message = "Expected the full CIS section 5 metric-alarm set (>= 15 alarms, 5.1-5.15)."
  }
}
