# CIS 2.16 — a role granting access to the AWS Support Center so the account
# can manage incidents. Trusts the account root by default, or the supplied
# principal ARNs when provided.

data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}

locals {
  support_role_trust = length(var.support_role_trusted_principal_arns) > 0 ? var.support_role_trusted_principal_arns : ["arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"]
}

data "aws_iam_policy_document" "support_assume" {
  count = var.create_support_role ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = local.support_role_trust
    }
  }
}

resource "aws_iam_role" "support" {
  count = var.create_support_role ? 1 : 0

  name               = var.support_role_name
  assume_role_policy = data.aws_iam_policy_document.support_assume[0].json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "support" {
  count = var.create_support_role ? 1 : 0

  role       = aws_iam_role.support[0].name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AWSSupportAccess"
}
