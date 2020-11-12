

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_kms_alias" "chamber_key" {
  name = "${var.key_alias}"
}
locals {
  region = "${coalesce(var.region, data.aws_region.current.name)}"
  account_id = "${coalesce(var.account_id, data.aws_caller_identity.current.account_id)}"
  namespace_parameters_arn = "arn:aws:ssm:${local.region}:${local.account_id}:parameter/${var.namespace}"
}

data "aws_iam_policy_document" "read_policy" {
  statement {
    actions = ["ssm:DescribeParameters"]
    resources = ["*"]
  }
  statement {
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath"
    ]
    resources = ["${local.namespace_parameters_arn}"]
  }
  statement {
    actions = ["kms:Decrypt"]
    resources = ["${data.aws_kms_alias.chamber_key.target_key_arn}"]
    condition {
      test = "StringLike"
      values = ["${local.namespace_parameters_arn}"]
      variable = "kms:EncryptionContext:PARAMETER_ARN"
    }
  }
}

data "aws_iam_policy_document" "readwrite_policy" {
  statement {
    actions = ["ssm:DescribeParameters"]
    resources = ["*"]
  }
  statement {
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParameterHistory",
      "ssm:GetParametersByPath",
      "ssm:PutParameter",
      "ssm:DeleteParameter",
      "ssm:DeleteParameters"
    ]
    resources = ["${local.namespace_parameters_arn}"]
  }
  // Read (decrypt)
  statement {
    actions = ["kms:Decrypt"]
    resources = ["${data.aws_kms_alias.chamber_key.target_key_arn}"]
    condition {
      test = "StringLike"
      values = ["${local.namespace_parameters_arn}"]
      variable = "kms:EncryptionContext:PARAMETER_ARN"
    }
  }
  // Write (encrypt)
  statement {
    actions = ["kms:Encrypt"]
    resources = ["${data.aws_kms_alias.chamber_key.target_key_arn}"]
  }
}
