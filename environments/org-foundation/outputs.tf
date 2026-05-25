output "trail_arn" {
  description = "ARN of the organization CloudTrail."
  value       = module.cloudtrail.trail_arn
}

output "cloudtrail_kms_key_arn" {
  description = "KMS key ARN encrypting CloudTrail logs."
  value       = module.cloudtrail.kms_key_arn
}

output "security_events_sns_topic_arn" {
  description = "SNS topic ARN for the EventBridge CIS security-event rules."
  value       = module.monitoring_events.sns_topic_arn
}

output "config_bucket" {
  description = "Name of the central AWS Config delivery bucket (null when Config is disabled)."
  value       = try(aws_s3_bucket.config[0].id, null)
}

output "home_analyzer_arn" {
  description = "IAM Access Analyzer ARN created in the home region."
  value       = module.regional_us_east_1.analyzer_arn
}
