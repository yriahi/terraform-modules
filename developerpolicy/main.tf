
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  region = "${coalesce(var.region, data.aws_region.current.name)}"
  account_id = "${coalesce(var.account_id, data.aws_caller_identity.current.account_id)}"
}


/**
 * Cloudwatch - allows metric access, and log access to tagged log streams.
 */
data "aws_iam_policy_document" "cloudwatch" {
  statement {
    effect = "Allow"
    actions = [
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:ListMetrics",
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "logs:Describe*",
      "logs:List*",
      "logs:Get*",
    ]
    resources = ["*"]
    condition {
      test = "StringEquals"
      values = ["${var.application}"]
      variable = "logs:ResourceTag/application"
    }
    condition {
      test = "StringEquals"
      values = ["${var.environment}"]
      variable = "logs:ResourceTag/environment"
    }
  }
}

/**
 * EC2 - Allows Start/Start/Reboot/Terminate access to tagged instances.
 */
data "aws_iam_policy_document" "ec2" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:Describe*",
      "elasticloadbalancing:Describe*"
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "ec2:StopInstances",
      "ec2:StartInstances",
      "ec2:TerminateInstances",
      "ec2:RebootInstances",
    ]
    resources = ["*"]
    condition {
      test = "StringEquals"
      values = ["${var.application}"]
      variable = "ec2:ResourceTag/application"
    }
    condition {
      test = "StringEquals"
      values = ["${var.environment}"]
      variable = "ec2:ResourceTag/environment"
    }
  }
}

/**
 * SSM - Allows SSM session manager access on any tagged instance.
 */
data "aws_iam_policy_document" "ssm" {
  statement {
    effect = "Allow"
    actions = [
      "ssm:DescribeInstance*",
      "ssm:DescribeSessions",
      "ssm:GetConnectionStatus"
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = ["ssm:StartSession"]
    resources = [
      "arn:aws:ec2:${local.region}:${local.account_id}:instance/*"
    ]
    condition {
      test = "StringLike"
      values = ["${var.application}"]
      variable = "ssm:resourceTag/application"
    }
    condition {
      test = "StringLike"
      values = ["${var.environment}"]
      variable = "ssm:resourceTag/environment"
    }
  }
  statement {
    effect = "Allow"
    actions = ["ssm:TerminateSession"]
    resources = ["arn:aws:ssm:${local.region}:${local.account_id}:session/$${aws:username}-*"]
  }
}

/**
 * RDS - Allows log/start/stop/reboot access to any tagged instance.
 */
data "aws_iam_policy_document" "rds" {
  statement {
    actions = [
      "rds:Describe*"
    ]
    resources = ["*"]
  }
  statement {
    actions = [
      "rds:StopDBInstance",
      "rds:StartDBInstance",
      "rds:RebootDBInstance",
      "rds:DownloadDBLogFilePortion",
      "rds:ListTagsForResource",
      "rds:CreateDBSnapshot"
    ]
    resources = ["*"]
    condition {
      test = "StringEquals"
      values = ["${var.application}"]
      variable = "rds:db-tag/application"
    }
    condition {
      test = "StringEquals"
      values = ["${var.environment}"]
      variable = "rds:db-tag/environment"
    }
  }
  statement {
    actions = [
      "rds:Describe*",
      "rds:StopDBInstance",
      "rds:StartDBInstance",
      "rds:RebootDBInstance",
      "rds:DownloadDBLogFilePortion",
      "rds:ListTagsForResource",
      "rds:CreateDBSnapshot"
    ]
    resources = ["*"]
    condition {
      test = "StringEquals"
      values = ["${var.application}"]
      variable = "rds:cluster-tag/application"
    }
    condition {
      test = "StringEquals"
      values = ["${var.environment}"]
      variable = "rds:cluster-tag/environment"
    }
  }
  statement {
    effect = "Allow"
    actions = ["pi:*"]
    resources = ["arn:aws:pi:${local.region}:${local.account_id}:metrics/rds/*"]
  }
}
