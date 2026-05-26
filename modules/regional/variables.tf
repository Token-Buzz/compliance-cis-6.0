variable "region_name" {
  description = "AWS region this composition instance manages. Used for resource naming."
  type        = string
}

# When true this is the home region: Config records global resource types,
# the Config organization aggregator is created, and Security Hub creates the
# cross-region finding aggregator. Exactly one regional instance is home.
variable "is_home_region" {
  type    = bool
  default = false
}

variable "name_prefix" {
  type    = string
  default = "cis"
}

variable "config_s3_bucket_name" {
  description = "Central AWS Config delivery bucket (created once in the root). Required only when enable_config = true; omit (null) when Config is disabled."
  type        = string
  default     = null
}

# The SHARED global Config recorder role, created once in the root and passed
# to every region so each region does not create its own IAM role (IAM is
# global and per-region roles would collide on name).
# Required only when enable_config = true; omit (null) when Config is disabled.
variable "config_iam_role_arn" {
  type    = string
  default = null
}

# Required only when is_home_region: the role assumed by the org aggregator.
variable "config_aggregator_role_arn" {
  type    = string
  default = null
}

variable "enable_config" {
  type    = bool
  default = false
}

variable "enable_security_hub" {
  type    = bool
  default = false
}

variable "enable_access_analyzer" {
  type    = bool
  default = true
}

variable "enable_guardduty" {
  type    = bool
  default = false
}

variable "analyzer_type" {
  type    = string
  default = "ORGANIZATION"
}

variable "restrict_default_security_group" {
  type    = bool
  default = true
}

variable "enable_ebs_default_encryption" {
  type    = bool
  default = true
}

variable "tags" {
  type    = map(string)
  default = {}
}
