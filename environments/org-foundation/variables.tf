variable "tags" {
  description = "Tags applied to every resource via provider default_tags and module tags."
  type        = map(string)
  default     = {}
}

variable "trail_name" {
  description = "Name of the organization CloudTrail."
  type        = string
  default     = "org-cloudtrail"
}

# REQUIRED: globally-unique S3 bucket name for CloudTrail log delivery.
variable "trail_log_bucket_name" {
  description = "Globally-unique S3 bucket name for CloudTrail log delivery."
  type        = string
}

# REQUIRED: globally-unique S3 bucket name for AWS Config delivery.
variable "config_log_bucket_name" {
  description = "Globally-unique S3 bucket name for AWS Config delivery."
  type        = string
}

variable "is_organization_trail" {
  description = "When true the CloudTrail is an organization trail covering all member accounts."
  type        = bool
  default     = true
}

variable "s3_read_event_bucket_arns" {
  description = "S3 bucket ARNs for which CloudTrail records object-level read data events."
  type        = list(string)
  default     = []
}

variable "alarm_email" {
  description = "Email subscribed to the CIS metric-alarm SNS topic. Null leaves the topic without a subscription."
  type        = string
  default     = null
}

variable "log_retention_days" {
  description = "Lifecycle expiration (days) for objects in the Config delivery bucket."
  type        = number
  default     = 365
}

# CIS 2.1 — primary account contact. Shape matches modules/iam-baseline.
variable "primary_contact" {
  type = object({
    full_name          = string
    address_line_1     = string
    city               = string
    country_code       = string
    postal_code        = string
    phone_number       = string
    address_line_2     = optional(string)
    address_line_3     = optional(string)
    district_or_county = optional(string)
    state_or_region    = optional(string)
    company_name       = optional(string)
    website_url        = optional(string)
  })
  default = null
}

# CIS 2.2 — SECURITY alternate contact. Shape matches modules/iam-baseline.
variable "security_contact" {
  type = object({
    name          = string
    title         = string
    email_address = string
    phone_number  = string
  })
  default = null
}

# Off by default for cost. Compensating controls (Prowler scans + Terraform
# drift detection) replace continuous AWS Config recording.
variable "enable_aws_config" {
  description = "Enable AWS Config recorders + delivery (bucket, IAM roles) in every active region."
  type        = bool
  default     = false
}

# Off by default for cost. Compensating controls cover the same CIS checks.
variable "enable_security_hub" {
  description = "Enable Security Hub in every active region."
  type        = bool
  default     = false
}

variable "enable_guardduty" {
  description = "Enable GuardDuty in every active region."
  type        = bool
  default     = false
}

variable "restrict_default_security_group" {
  description = "Strip all rules from the default security group in every active region."
  type        = bool
  default     = true
}
