resource "aws_iam_account_password_policy" "this" {
  count = var.manage_password_policy ? 1 : 0

  minimum_password_length        = var.password_minimum_length
  password_reuse_prevention      = var.password_reuse_prevention
  max_password_age               = var.password_max_age
  require_lowercase_characters   = var.password_require_lowercase
  require_uppercase_characters   = var.password_require_uppercase
  require_numbers                = var.password_require_numbers
  require_symbols                = var.password_require_symbols
  allow_users_to_change_password = var.allow_users_to_change_password
  hard_expiry                    = var.hard_expiry
}

resource "aws_s3_account_public_access_block" "this" {
  count = var.enable_account_s3_block_public_access ? 1 : 0

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_account_primary_contact" "this" {
  count = var.primary_contact != null ? 1 : 0

  full_name          = var.primary_contact.full_name
  address_line_1     = var.primary_contact.address_line_1
  address_line_2     = var.primary_contact.address_line_2
  address_line_3     = var.primary_contact.address_line_3
  city               = var.primary_contact.city
  country_code       = var.primary_contact.country_code
  postal_code        = var.primary_contact.postal_code
  phone_number       = var.primary_contact.phone_number
  district_or_county = var.primary_contact.district_or_county
  state_or_region    = var.primary_contact.state_or_region
  company_name       = var.primary_contact.company_name
  website_url        = var.primary_contact.website_url
}

resource "aws_account_alternate_contact" "security" {
  count = var.security_contact != null ? 1 : 0

  alternate_contact_type = "SECURITY"
  name                   = var.security_contact.name
  title                  = var.security_contact.title
  email_address          = var.security_contact.email_address
  phone_number           = var.security_contact.phone_number
}
