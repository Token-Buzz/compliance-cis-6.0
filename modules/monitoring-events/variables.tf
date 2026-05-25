variable "sns_topic_name" {
  type    = string
  default = "cis-security-events"
}

variable "notification_email" {
  type    = string
  default = null
}

variable "existing_sns_topic_arn" {
  type    = string
  default = null
}

variable "enabled_rules" {
  type    = map(bool)
  default = {}
}

variable "tags" {
  type    = map(string)
  default = {}
}
