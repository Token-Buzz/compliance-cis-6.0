# Per-region guardrails. One regional module instance per active region, each
# bound to its own provider. Static blocks are required because Terraform does
# not allow for_each over providers. us-east-1 is the home region (default
# provider): it records global resource types and creates the Config org
# aggregator and the Security Hub finding aggregator.

locals {
  # Null when AWS Config is disabled; the regional modules tolerate null inputs
  # because their Config child module is gated off in that case.
  config_bucket_name    = var.enable_aws_config ? aws_s3_bucket.config[0].id : null
  config_role_arn       = var.enable_aws_config ? aws_iam_role.config_recorder[0].arn : null
  config_aggregator_arn = var.enable_aws_config ? aws_iam_role.config_aggregator[0].arn : null
}

module "regional_us_east_1" {
  source = "../../modules/regional"

  providers = {
    aws = aws
  }

  region_name    = "us-east-1"
  is_home_region = true

  enable_config       = var.enable_aws_config
  enable_security_hub = var.enable_security_hub

  config_s3_bucket_name      = local.config_bucket_name
  config_iam_role_arn        = local.config_role_arn
  config_aggregator_role_arn = local.config_aggregator_arn

  enable_guardduty                = var.enable_guardduty
  restrict_default_security_group = var.restrict_default_security_group
  analyzer_type                   = var.analyzer_type
  enable_ebs_default_encryption   = true

  tags = var.tags
}

module "regional_us_east_2" {
  source = "../../modules/regional"

  providers = {
    aws = aws.us_east_2
  }

  region_name    = "us-east-2"
  is_home_region = false

  enable_config       = var.enable_aws_config
  enable_security_hub = var.enable_security_hub

  config_s3_bucket_name      = local.config_bucket_name
  config_iam_role_arn        = local.config_role_arn
  config_aggregator_role_arn = null

  enable_guardduty                = var.enable_guardduty
  restrict_default_security_group = var.restrict_default_security_group
  analyzer_type                   = var.analyzer_type
  enable_ebs_default_encryption   = true

  tags = var.tags
}

module "regional_us_west_1" {
  source = "../../modules/regional"

  providers = {
    aws = aws.us_west_1
  }

  region_name    = "us-west-1"
  is_home_region = false

  enable_config       = var.enable_aws_config
  enable_security_hub = var.enable_security_hub

  config_s3_bucket_name      = local.config_bucket_name
  config_iam_role_arn        = local.config_role_arn
  config_aggregator_role_arn = null

  enable_guardduty                = var.enable_guardduty
  restrict_default_security_group = var.restrict_default_security_group
  analyzer_type                   = var.analyzer_type
  enable_ebs_default_encryption   = true

  tags = var.tags
}

module "regional_us_west_2" {
  source = "../../modules/regional"

  providers = {
    aws = aws.us_west_2
  }

  region_name    = "us-west-2"
  is_home_region = false

  enable_config       = var.enable_aws_config
  enable_security_hub = var.enable_security_hub

  config_s3_bucket_name      = local.config_bucket_name
  config_iam_role_arn        = local.config_role_arn
  config_aggregator_role_arn = null

  enable_guardduty                = var.enable_guardduty
  restrict_default_security_group = var.restrict_default_security_group
  analyzer_type                   = var.analyzer_type
  enable_ebs_default_encryption   = true

  tags = var.tags
}

module "regional_ca_central_1" {
  source = "../../modules/regional"

  providers = {
    aws = aws.ca_central_1
  }

  region_name    = "ca-central-1"
  is_home_region = false

  enable_config       = var.enable_aws_config
  enable_security_hub = var.enable_security_hub

  config_s3_bucket_name      = local.config_bucket_name
  config_iam_role_arn        = local.config_role_arn
  config_aggregator_role_arn = null

  enable_guardduty                = var.enable_guardduty
  restrict_default_security_group = var.restrict_default_security_group
  analyzer_type                   = var.analyzer_type
  enable_ebs_default_encryption   = true

  tags = var.tags
}

module "regional_eu_west_1" {
  source = "../../modules/regional"

  providers = {
    aws = aws.eu_west_1
  }

  region_name    = "eu-west-1"
  is_home_region = false

  enable_config       = var.enable_aws_config
  enable_security_hub = var.enable_security_hub

  config_s3_bucket_name      = local.config_bucket_name
  config_iam_role_arn        = local.config_role_arn
  config_aggregator_role_arn = null

  enable_guardduty                = var.enable_guardduty
  restrict_default_security_group = var.restrict_default_security_group
  analyzer_type                   = var.analyzer_type
  enable_ebs_default_encryption   = true

  tags = var.tags
}

module "regional_eu_west_2" {
  source = "../../modules/regional"

  providers = {
    aws = aws.eu_west_2
  }

  region_name    = "eu-west-2"
  is_home_region = false

  enable_config       = var.enable_aws_config
  enable_security_hub = var.enable_security_hub

  config_s3_bucket_name      = local.config_bucket_name
  config_iam_role_arn        = local.config_role_arn
  config_aggregator_role_arn = null

  enable_guardduty                = var.enable_guardduty
  restrict_default_security_group = var.restrict_default_security_group
  analyzer_type                   = var.analyzer_type
  enable_ebs_default_encryption   = true

  tags = var.tags
}

module "regional_eu_west_3" {
  source = "../../modules/regional"

  providers = {
    aws = aws.eu_west_3
  }

  region_name    = "eu-west-3"
  is_home_region = false

  enable_config       = var.enable_aws_config
  enable_security_hub = var.enable_security_hub

  config_s3_bucket_name      = local.config_bucket_name
  config_iam_role_arn        = local.config_role_arn
  config_aggregator_role_arn = null

  enable_guardduty                = var.enable_guardduty
  restrict_default_security_group = var.restrict_default_security_group
  analyzer_type                   = var.analyzer_type
  enable_ebs_default_encryption   = true

  tags = var.tags
}

module "regional_eu_central_1" {
  source = "../../modules/regional"

  providers = {
    aws = aws.eu_central_1
  }

  region_name    = "eu-central-1"
  is_home_region = false

  enable_config       = var.enable_aws_config
  enable_security_hub = var.enable_security_hub

  config_s3_bucket_name      = local.config_bucket_name
  config_iam_role_arn        = local.config_role_arn
  config_aggregator_role_arn = null

  enable_guardduty                = var.enable_guardduty
  restrict_default_security_group = var.restrict_default_security_group
  analyzer_type                   = var.analyzer_type
  enable_ebs_default_encryption   = true

  tags = var.tags
}

module "regional_eu_north_1" {
  source = "../../modules/regional"

  providers = {
    aws = aws.eu_north_1
  }

  region_name    = "eu-north-1"
  is_home_region = false

  enable_config       = var.enable_aws_config
  enable_security_hub = var.enable_security_hub

  config_s3_bucket_name      = local.config_bucket_name
  config_iam_role_arn        = local.config_role_arn
  config_aggregator_role_arn = null

  enable_guardduty                = var.enable_guardduty
  restrict_default_security_group = var.restrict_default_security_group
  analyzer_type                   = var.analyzer_type
  enable_ebs_default_encryption   = true

  tags = var.tags
}

module "regional_ap_south_1" {
  source = "../../modules/regional"

  providers = {
    aws = aws.ap_south_1
  }

  region_name    = "ap-south-1"
  is_home_region = false

  enable_config       = var.enable_aws_config
  enable_security_hub = var.enable_security_hub

  config_s3_bucket_name      = local.config_bucket_name
  config_iam_role_arn        = local.config_role_arn
  config_aggregator_role_arn = null

  enable_guardduty                = var.enable_guardduty
  restrict_default_security_group = var.restrict_default_security_group
  analyzer_type                   = var.analyzer_type
  enable_ebs_default_encryption   = true

  tags = var.tags
}

module "regional_ap_northeast_1" {
  source = "../../modules/regional"

  providers = {
    aws = aws.ap_northeast_1
  }

  region_name    = "ap-northeast-1"
  is_home_region = false

  enable_config       = var.enable_aws_config
  enable_security_hub = var.enable_security_hub

  config_s3_bucket_name      = local.config_bucket_name
  config_iam_role_arn        = local.config_role_arn
  config_aggregator_role_arn = null

  enable_guardduty                = var.enable_guardduty
  restrict_default_security_group = var.restrict_default_security_group
  analyzer_type                   = var.analyzer_type
  enable_ebs_default_encryption   = true

  tags = var.tags
}

module "regional_ap_northeast_2" {
  source = "../../modules/regional"

  providers = {
    aws = aws.ap_northeast_2
  }

  region_name    = "ap-northeast-2"
  is_home_region = false

  enable_config       = var.enable_aws_config
  enable_security_hub = var.enable_security_hub

  config_s3_bucket_name      = local.config_bucket_name
  config_iam_role_arn        = local.config_role_arn
  config_aggregator_role_arn = null

  enable_guardduty                = var.enable_guardduty
  restrict_default_security_group = var.restrict_default_security_group
  analyzer_type                   = var.analyzer_type
  enable_ebs_default_encryption   = true

  tags = var.tags
}

module "regional_ap_northeast_3" {
  source = "../../modules/regional"

  providers = {
    aws = aws.ap_northeast_3
  }

  region_name    = "ap-northeast-3"
  is_home_region = false

  enable_config       = var.enable_aws_config
  enable_security_hub = var.enable_security_hub

  config_s3_bucket_name      = local.config_bucket_name
  config_iam_role_arn        = local.config_role_arn
  config_aggregator_role_arn = null

  enable_guardduty                = var.enable_guardduty
  restrict_default_security_group = var.restrict_default_security_group
  analyzer_type                   = var.analyzer_type
  enable_ebs_default_encryption   = true

  tags = var.tags
}

module "regional_ap_southeast_1" {
  source = "../../modules/regional"

  providers = {
    aws = aws.ap_southeast_1
  }

  region_name    = "ap-southeast-1"
  is_home_region = false

  enable_config       = var.enable_aws_config
  enable_security_hub = var.enable_security_hub

  config_s3_bucket_name      = local.config_bucket_name
  config_iam_role_arn        = local.config_role_arn
  config_aggregator_role_arn = null

  enable_guardduty                = var.enable_guardduty
  restrict_default_security_group = var.restrict_default_security_group
  analyzer_type                   = var.analyzer_type
  enable_ebs_default_encryption   = true

  tags = var.tags
}

module "regional_ap_southeast_2" {
  source = "../../modules/regional"

  providers = {
    aws = aws.ap_southeast_2
  }

  region_name    = "ap-southeast-2"
  is_home_region = false

  enable_config       = var.enable_aws_config
  enable_security_hub = var.enable_security_hub

  config_s3_bucket_name      = local.config_bucket_name
  config_iam_role_arn        = local.config_role_arn
  config_aggregator_role_arn = null

  enable_guardduty                = var.enable_guardduty
  restrict_default_security_group = var.restrict_default_security_group
  analyzer_type                   = var.analyzer_type
  enable_ebs_default_encryption   = true

  tags = var.tags
}

module "regional_sa_east_1" {
  source = "../../modules/regional"

  providers = {
    aws = aws.sa_east_1
  }

  region_name    = "sa-east-1"
  is_home_region = false

  enable_config       = var.enable_aws_config
  enable_security_hub = var.enable_security_hub

  config_s3_bucket_name      = local.config_bucket_name
  config_iam_role_arn        = local.config_role_arn
  config_aggregator_role_arn = null

  enable_guardduty                = var.enable_guardduty
  restrict_default_security_group = var.restrict_default_security_group
  analyzer_type                   = var.analyzer_type
  enable_ebs_default_encryption   = true

  tags = var.tags
}
