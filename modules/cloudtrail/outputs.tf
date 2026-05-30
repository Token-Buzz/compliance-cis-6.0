output "cloudwatch_log_group_name" {
  value = try(aws_cloudwatch_log_group.this[0].name, null)
}

output "cloudwatch_log_group_arn" {
  value = try(aws_cloudwatch_log_group.this[0].arn, null)
}

output "kms_key_arn" {
  value = local.kms_key_arn
}

output "s3_bucket_id" {
  value = aws_s3_bucket.this.id
}

output "s3_bucket_arn" {
  value = aws_s3_bucket.this.arn
}

output "trail_arn" {
  value = aws_cloudtrail.this.arn
}

output "access_log_bucket_id" {
  value = try(aws_s3_bucket.access_logs[0].id, null)
}

output "access_log_bucket_arn" {
  value = try(aws_s3_bucket.access_logs[0].arn, null)
}
