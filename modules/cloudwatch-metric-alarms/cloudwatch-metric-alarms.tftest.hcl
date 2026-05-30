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

run "organizations_filter_matches_prowler_strict_ordered_regex" {
  # CIS 5.15 regression guard. Prowler's check
  # cloudwatch_log_metric_filter_aws_organizations_changes matches the stored
  # filterPattern against a STRICT ORDERED regex: every listed event must be
  # present and in sequence. This asserts the three events that were missing
  # before (CancelHandshake, CreateOrganization, EnableAllFeatures) are present,
  # plus the eventSource clause. If any of these are dropped again, 5.15 FAILs.
  command = plan

  variables {
    log_group_name = "/aws/cloudtrail/test"
    sns_topic_arn  = "arn:aws:sns:us-east-1:123456789012:test"
  }

  assert {
    condition     = strcontains(aws_cloudwatch_log_metric_filter.this["organizations_changes"].pattern, "$.eventSource = organizations.amazonaws.com")
    error_message = "CIS 5.15 filter must AND on eventSource = organizations.amazonaws.com first."
  }

  assert {
    condition     = strcontains(aws_cloudwatch_log_metric_filter.this["organizations_changes"].pattern, "\"CancelHandshake\"")
    error_message = "CIS 5.15 filter is missing CancelHandshake (Prowler strict-ordered regex will FAIL)."
  }

  assert {
    condition     = strcontains(aws_cloudwatch_log_metric_filter.this["organizations_changes"].pattern, "\"CreateOrganization\"")
    error_message = "CIS 5.15 filter is missing CreateOrganization (Prowler strict-ordered regex will FAIL)."
  }

  assert {
    condition     = strcontains(aws_cloudwatch_log_metric_filter.this["organizations_changes"].pattern, "\"EnableAllFeatures\"")
    error_message = "CIS 5.15 filter is missing EnableAllFeatures (Prowler strict-ordered regex will FAIL)."
  }
}
