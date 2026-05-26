variable "enable_cis_standard" {
  type    = bool
  default = true
}

variable "cis_standard_arn" {
  type    = string
  default = null
}

# Cost control: the AWS-managed default standards are not auto-enabled.
variable "enable_default_standards" {
  type    = bool
  default = false
}

# Finding aggregation is regional; enable it only in the home region.
variable "create_finding_aggregator" {
  type    = bool
  default = false
}

variable "tags" {
  type    = map(string)
  default = {}
}
