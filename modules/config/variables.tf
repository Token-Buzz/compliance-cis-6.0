variable "s3_bucket_name" {
  type = string
}

variable "s3_key_prefix" {
  type    = string
  default = "config"
}

# When null the module creates an IAM role for Config; otherwise the supplied role is used.
variable "iam_role_arn" {
  type    = string
  default = null
}

# Global resource types (IAM, etc.) are global; record them in the home region only to avoid duplicate recording.
variable "include_global_resource_types" {
  type    = bool
  default = false
}

variable "sns_topic_arn" {
  type    = string
  default = null
}

variable "enable_organization_aggregator" {
  type    = bool
  default = false
}

variable "aggregator_name" {
  type    = string
  default = "org-config-aggregator"
}

# Required when enable_organization_aggregator is true (enforced via lifecycle precondition).
variable "aggregator_role_arn" {
  type    = string
  default = null
}

variable "tags" {
  type    = map(string)
  default = {}
}
