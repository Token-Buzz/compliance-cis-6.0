output "ebs_default_encryption_enabled" {
  value = var.enable_ebs_default_encryption
}

output "default_security_group_id" {
  value = try(aws_default_security_group.this[0].id, null)
}
