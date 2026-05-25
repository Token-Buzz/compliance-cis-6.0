variable "analyzer_name" {
  type = string
}

variable "analyzer_type" {
  type    = string
  default = "ORGANIZATION"

  validation {
    condition     = contains(["ACCOUNT", "ORGANIZATION"], var.analyzer_type)
    error_message = "analyzer_type must be either \"ACCOUNT\" or \"ORGANIZATION\"."
  }
}

variable "tags" {
  type    = map(string)
  default = {}
}
