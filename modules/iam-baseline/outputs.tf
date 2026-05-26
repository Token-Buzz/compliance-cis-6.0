output "password_policy_managed" {
  value = var.manage_password_policy
}

output "account_s3_block_public_access_enabled" {
  value = var.enable_account_s3_block_public_access
}

output "support_role_arn" {
  value = try(aws_iam_role.support[0].arn, null)
}
