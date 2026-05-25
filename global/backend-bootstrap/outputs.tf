output "state_bucket" {
  description = "Name of the S3 bucket holding Terraform remote state."
  value       = aws_s3_bucket.state.id
}

output "region" {
  description = "AWS region where the backend resources live."
  value       = var.region
}
