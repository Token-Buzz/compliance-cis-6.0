provider "aws" {
  region                      = "us-east-1"
  access_key                  = "mock"
  secret_key                  = "mock"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
}

run "creates_full_cis_alarm_set" {
  command = plan

  variables {
    cloudwatch_log_group_name = "test"
    alarm_email               = null
  }

  assert {
    condition     = length(aws_cloudwatch_metric_alarm.this) >= 14
    error_message = "Expected the full CIS section 5 alarm set (>= 14 alarms)."
  }
}
