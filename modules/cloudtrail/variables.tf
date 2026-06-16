variable "trail_name" {
  type = string
}

variable "log_bucket_name" {
  type = string
}

variable "is_organization_trail" {
  type    = bool
  default = false
}

variable "kms_key_arn" {
  type    = string
  default = null
}

variable "create_kms_key" {
  type    = bool
  default = false
}

variable "deliver_to_cloudwatch_logs" {
  type    = bool
  default = true
}

variable "cloudwatch_logs_retention_days" {
  type    = number
  default = 365
}

variable "s3_log_retention_days" {
  type    = number
  default = 365
}

variable "enable_access_logging" {
  type    = bool
  default = true
}

variable "force_destroy" {
  description = "Allow Terraform to delete the trail log bucket (and access-log bucket) even when non-empty, permanently purging stored logs. Default false. Set true to enable tearing the trail down via `terraform destroy`/count=0."
  type        = bool
  default     = false
}

variable "access_log_bucket_name" {
  type    = string
  default = null
}

variable "s3_data_event_write_all_buckets" {
  type    = bool
  default = true
}

variable "s3_read_event_bucket_arns" {
  type    = list(string)
  default = []
}

variable "enable_lambda_data_events" {
  type    = bool
  default = false
}

variable "tags" {
  type    = map(string)
  default = {}
}
