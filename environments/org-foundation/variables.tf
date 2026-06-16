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
  description = "False = account-level trail (this deployment targets a member account, not the Org management account); true would require the management account."
  type        = bool
  default     = false
}

variable "analyzer_type" {
  description = "IAM Access Analyzer scope. ACCOUNT for a member account; ORGANIZATION only if this is the Org management/delegated-admin account."
  type        = string
  default     = "ACCOUNT"
  validation {
    condition     = contains(["ACCOUNT", "ORGANIZATION"], var.analyzer_type)
    error_message = "analyzer_type must be ACCOUNT or ORGANIZATION."
  }
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

# Opt-in: CIS §5 CloudWatch metric-filter alarms (5.1–5.14).
# When true, a dedicated management-events-only CloudTrail trail is created that
# delivers to CloudWatch Logs, plus ~14 metric filters + alarms reading that log
# group. Costs ~$2–3/mo. Default false keeps the near-$0 posture; the
# EventBridge→SNS rules in module.monitoring_events remain the always-on
# compensating control regardless of this setting.
variable "enable_cloudwatch_alarms" {
  description = "Opt-in CIS §5 CloudWatch metric-filter alarms (5.1–5.14); adds a dedicated management-events-only CloudTrail delivering to CloudWatch Logs + ~14 alarms; costs ~$2–3/mo; default off keeps the near-$0 posture (EventBridge→SNS in monitoring-events remains the always-on compensating control)."
  type        = bool
  default     = false
}

# Globally-unique S3 bucket name for the management-events-only monitoring trail.
# REQUIRED when enable_cloudwatch_alarms = true; unused (and may be null) otherwise.
# Cross-variable validation is enforced via a check block in main.tf because
# Terraform variable validation blocks cannot reference other variables.
variable "monitoring_trail_log_bucket_name" {
  description = "Globally-unique S3 bucket for the management-events-only monitoring trail. REQUIRED when enable_cloudwatch_alarms = true."
  type        = string
  default     = null
}

# Off by default for cost. CloudTrail S3 object-level WRITE data events across all
# buckets are billed per event (~$0.00002/event) and dominate the CloudTrail bill.
# Management events (always recorded by the primary trail) stay free. Turn this on
# only while running a CIS/Prowler compliance scan that needs S3 data-event
# coverage, then turn it back off.
variable "enable_s3_data_events" {
  description = "Record CloudTrail S3 object-level WRITE data events across all buckets. Billed per event; default off. Turn on only while running a compliance scan."
  type        = bool
  default     = false
}

# Master on/off switch for ALL CloudTrail features in this root: the primary
# organization/account trail, its log + access-log S3 buckets, the optional
# §5 monitoring trail, and the §5 CloudWatch metric-filter alarms. Default OFF
# per an explicit cost directive (no CloudTrail logs needed at this time).
#
# TRADE-OFF: CloudTrail is a *free* CIS control (management events on a single
# trail cost nothing). Disabling it fails CIS 3.x (CloudTrail enabled / multi-
# region / log-file validation) and removes the data source the §5 monitoring
# relies on. Re-enable by setting this true. The always-on, free EventBridge→SNS
# rules in module.monitoring_events are unaffected by this toggle.
variable "enable_cloudtrail" {
  description = "Master on/off switch for all CloudTrail features (primary trail, log/access-log buckets, §5 monitoring trail, §5 CloudWatch alarms). Default off per cost directive; disabling fails CIS 3.x. EventBridge→SNS rules remain regardless."
  type        = bool
  default     = false
}
