output "analyzer_arn" {
  value = try(module.access_analyzer[0].analyzer_arn, null)
}

output "config_recorder_name" {
  value = try(module.config[0].recorder_name, null)
}

output "securityhub_account_id" {
  value = try(module.security_hub[0].securityhub_account_id, null)
}

output "detector_id" {
  value = try(module.guardduty.detector_id, null)
}
