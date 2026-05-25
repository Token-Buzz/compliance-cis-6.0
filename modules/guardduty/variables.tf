variable "enable" {
  type    = bool
  default = false
}

variable "finding_publishing_frequency" {
  type    = string
  default = "SIX_HOURS"
}

variable "enable_s3_protection" {
  type    = bool
  default = false
}

variable "tags" {
  type    = map(string)
  default = {}
}
