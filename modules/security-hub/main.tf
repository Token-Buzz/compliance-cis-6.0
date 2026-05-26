data "aws_region" "current" {}

data "aws_partition" "current" {}

locals {
  # CIS AWS Foundations Benchmark standards-subscription ARN for this region/partition.
  cis_arn = "arn:${data.aws_partition.current.partition}:securityhub:${data.aws_region.current.name}::standards/cis-aws-foundations-benchmark/v/1.4.0"
}

resource "aws_securityhub_account" "this" {
  enable_default_standards = var.enable_default_standards
}

resource "aws_securityhub_standards_subscription" "cis" {
  count = var.enable_cis_standard ? 1 : 0

  standards_arn = coalesce(var.cis_standard_arn, local.cis_arn)

  depends_on = [aws_securityhub_account.this]
}

resource "aws_securityhub_finding_aggregator" "this" {
  count = var.create_finding_aggregator ? 1 : 0

  linking_mode = "ALL_REGIONS"

  depends_on = [aws_securityhub_account.this]
}
