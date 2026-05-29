output "password_policy_managed" {
  value = var.manage_password_policy
}

output "account_s3_block_public_access_enabled" {
  value = var.enable_account_s3_block_public_access
}

output "support_role_arn" {
  value = try(aws_iam_role.support[0].arn, null)
}

output "iam_group_names" {
  value = [for g in aws_iam_group.this : g.name]
}

output "break_glass_role_arn" {
  value = try(aws_iam_role.break_glass[0].arn, null)
}
