variable "log_group_name" {
  description = "Name of the CloudWatch Logs log group fed by the monitoring CloudTrail trail."
  type        = string
}

variable "sns_topic_arn" {
  description = "ARN of the existing SNS topic to send alarm notifications into."
  type        = string
}

variable "metric_namespace" {
  description = "CloudWatch metric namespace for the CIS metric filters."
  type        = string
  default     = "CISBenchmark"
}

variable "enabled_filters" {
  description = "Optional per-filter toggle. Omitting a key is equivalent to true. Set a key to false to disable that specific filter/alarm."
  type        = map(bool)
  default     = {}
}

variable "tags" {
  description = "Tags applied to every resource created by this module."
  type        = map(string)
  default     = {}
}
