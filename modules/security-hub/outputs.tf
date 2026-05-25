output "securityhub_account_id" {
  value = aws_securityhub_account.this.id
}

output "cis_subscription_arn" {
  value = var.enable_cis_standard ? aws_securityhub_standards_subscription.cis[0].standards_arn : null
}
