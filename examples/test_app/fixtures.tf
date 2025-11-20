data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

module "vpc" {
  source  = "aws-ia/vpc/aws"
  version = "4.5.0"

  name       = var.application_name
  cidr_block = "10.254.254.0/24"
  az_count   = 2

  subnets = {
    private = {
      netmask = 26
    }
  }
}

resource "aws_iam_role" "rds_proxy" {
  name        = "${var.application_name}-rds-proxy"
  description = "Role needed by RDS Proxy for ${var.application_name}"

  assume_role_policy = jsonencode({
    "Version" = "2012-10-17",
    "Statement" = [
      {
        "Sid"    = "RDSAssume",
        "Effect" = "Allow",
        "Principal" = {
          "Service" = "rds.amazonaws.com"
        },
        "Action" = "sts:AssumeRole"
      }
    ]
  })
}

data "aws_iam_policy_document" "rds_proxy" {
  statement {
    sid    = "DecryptRDSSecrets"
    effect = "Allow"
    actions = [
      "kms:Decrypt"
    ]
    resources = ["arn:aws:kms:*:*:key/*"]
    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["secretsmanager.${data.aws_region.current.name}.amazonaws.com"]
    }
  }

  statement {
    sid    = "ListRDSSecrets"
    effect = "Allow"
    actions = [
      "secretsmanager:ListSecrets",
      "secretsmanager:GetRandomPassword"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "GetRDSSecrets"
    effect = "Allow"
    actions = [
      "secretsmanager:ListSecretVersionIds",
      "secretsmanager:GetSecretValue",
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:DescribeSecret"
    ]
    resources = [
      "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:constr/${var.application_name}-rds-password-*"
    ]
  }
}

resource "aws_iam_policy" "rds_proxy" {
  name        = "${var.application_name}-rds-proxy"
  description = "Policy for RDS Proxy role"
  policy      = data.aws_iam_policy_document.rds_proxy.json
}

resource "aws_iam_role_policy_attachment" "rds_proxy" {
  role       = aws_iam_role.rds_proxy.name
  policy_arn = aws_iam_policy.rds_proxy.arn
}
