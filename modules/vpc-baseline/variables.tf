variable "enable_ebs_default_encryption" {
  type    = bool
  default = true
}

# When set, also pins the account-default EBS KMS key for this region;
# null leaves AWS to use the aws/ebs managed key.
variable "ebs_default_kms_key_arn" {
  type    = string
  default = null
}

variable "restrict_default_security_group" {
  type    = bool
  default = true
}

# When null and locking down the default SG, the default VPC is resolved
# via a data source.
variable "default_vpc_id" {
  type    = string
  default = null
}

variable "enable_flow_logs" {
  type    = bool
  default = false
}

variable "flow_logs_s3_destination_arn" {
  type    = string
  default = null
}

variable "flow_logs_traffic_type" {
  type    = string
  default = "ALL"

  validation {
    condition     = contains(["ACCEPT", "REJECT", "ALL"], var.flow_logs_traffic_type)
    error_message = "flow_logs_traffic_type must be one of \"ACCEPT\", \"REJECT\", or \"ALL\"."
  }
}

variable "tags" {
  type    = map(string)
  default = {}
}
