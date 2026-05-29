output "alarm_names" {
  description = "Names of the CloudWatch metric alarms created by this module."
  value       = keys(local.active_filters)
}

output "metric_filter_names" {
  description = "Names of the CloudWatch Logs metric filters created by this module."
  value       = keys(local.active_filters)
}
