variable "manage_password_policy" {
  type    = bool
  default = true
}

variable "password_minimum_length" {
  type    = number
  default = 14
}

variable "password_reuse_prevention" {
  type    = number
  default = 24
}

variable "password_max_age" {
  type    = number
  default = 90
}

variable "password_require_lowercase" {
  type    = bool
  default = true
}

variable "password_require_uppercase" {
  type    = bool
  default = true
}

variable "password_require_numbers" {
  type    = bool
  default = true
}

variable "password_require_symbols" {
  type    = bool
  default = true
}

variable "allow_users_to_change_password" {
  type    = bool
  default = true
}

variable "hard_expiry" {
  type    = bool
  default = false
}

variable "enable_account_s3_block_public_access" {
  type    = bool
  default = true
}

# CIS 2.1 — primary account contact. Null disables management so existing
# console-set values are not clobbered.
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

# CIS 2.2 — SECURITY alternate contact. Null disables management.
variable "security_contact" {
  type = object({
    name          = string
    title         = string
    email_address = string
    phone_number  = string
  })
  default = null
}

# CIS 2.16 — AWS Support access role.
variable "create_support_role" {
  type    = bool
  default = true
}

variable "support_role_name" {
  type    = string
  default = "AWSSupportAccessRole"
}

# When empty the role trusts the account root; otherwise it trusts these ARNs.
variable "support_role_trusted_principal_arns" {
  type    = list(string)
  default = []
}

# CIS 2.14 — attach policies to groups, not users. Each map key is the group
# name; members are names of EXISTING users (managed outside Terraform).
# Default {} creates zero resources (no-op).
variable "iam_groups" {
  type = map(object({
    managed_policy_arns = optional(list(string), [])
    members             = optional(list(string), [])
  }))
  default = {}
}

# Optional break-glass admin role scaffold. Fully gated and default-OFF, so it
# creates nothing until enabled. attach_customer_admin uses a customer-managed
# admin policy to retain emergency admin without tripping CIS 2.15 (which only
# flags the AWS-managed AdministratorAccess policy).
variable "break_glass_admin" {
  type = object({
    enabled                = optional(bool, false)
    role_name              = optional(string, "BreakGlassAdmin")
    trusted_principal_arns = optional(list(string), [])
    require_mfa            = optional(bool, true)
    attach_customer_admin  = optional(bool, true)
  })
  default = {}
}

variable "tags" {
  type    = map(string)
  default = {}
}
