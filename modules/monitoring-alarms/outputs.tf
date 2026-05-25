output "sns_topic_arn" {
  value = local.topic_arn
}

output "alarm_names" {
  value = keys(local.active_alarms)
}
