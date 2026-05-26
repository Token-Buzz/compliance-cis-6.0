output "sns_topic_arn" {
  value = local.topic_arn
}

output "rule_names" {
  value = keys(local.active_rules)
}
