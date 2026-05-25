variable "cloudwatch_log_group_name" {
  type = string
}

variable "sns_topic_name" {
  type    = string
  default = "cis-security-alarms"
}

variable "alarm_email" {
  type    = string
  default = null
}

variable "existing_sns_topic_arn" {
  type    = string
  default = null
}

variable "metric_namespace" {
  type    = string
  default = "CISBenchmark"
}

variable "enabled_alarms" {
  type    = map(bool)
  default = {}
}

variable "tags" {
  type    = map(string)
  default = {}
}
