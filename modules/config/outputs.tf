output "recorder_name" {
  value = aws_config_configuration_recorder.this.name
}

output "delivery_channel_id" {
  value = aws_config_delivery_channel.this.id
}

output "aggregator_arn" {
  value = var.enable_organization_aggregator ? aws_config_configuration_aggregator.org[0].arn : null
}
