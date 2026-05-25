# Global (account-wide) IAM created once in the root. AWS Config recorder roles
# are IAM resources (global), so one shared recorder role is created here and
# passed to every regional module — per-region roles would collide on name.

data "aws_partition" "current" {}

data "aws_iam_policy_document" "config_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
  }
}

# Shared recorder role used by the Config recorder in every active region.
resource "aws_iam_role" "config_recorder" {
  name               = "cis-config-recorder"
  assume_role_policy = data.aws_iam_policy_document.config_assume.json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "config_recorder" {
  role       = aws_iam_role.config_recorder.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWS_ConfigRole"
}

# Role assumed by the home-region Config organization aggregator to read member
# account configuration. Kept separate from the recorder role for least
# privilege and clearer auditing.
resource "aws_iam_role" "config_aggregator" {
  name               = "cis-config-aggregator"
  assume_role_policy = data.aws_iam_policy_document.config_assume.json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "config_aggregator" {
  role       = aws_iam_role.config_aggregator.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWS_ConfigRole"
}
