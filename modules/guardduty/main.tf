resource "aws_guardduty_detector" "this" {
  count = var.enable ? 1 : 0

  enable                       = true
  finding_publishing_frequency = var.finding_publishing_frequency

  datasources {
    s3_logs {
      enable = var.enable_s3_protection
    }
  }

  tags = var.tags
}
