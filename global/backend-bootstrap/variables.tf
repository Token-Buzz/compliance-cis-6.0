variable "region" {
  description = "AWS region in which to create the remote-state backend resources."
  type        = string
  # No default: must be supplied explicitly so the backend region is never ambiguous.
}

variable "state_bucket_name" {
  description = "Globally-unique name for the S3 bucket that stores Terraform remote state."
  type        = string
  # No default: bucket names are global and account-specific; force an explicit value.
}

variable "tags" {
  description = "Tags applied to all bootstrap resources."
  type        = map(string)
  default     = {}
}
