provider "aws" {
  region = "us-east-1"
}

run "creates_full_cis_event_rule_set" {
  command = plan

  variables {
    notification_email = null
  }

  assert {
    condition     = length(aws_cloudwatch_event_rule.this) >= 14
    error_message = "Expected the full CIS section 5 event-rule set (>= 14 rules)."
  }
}
