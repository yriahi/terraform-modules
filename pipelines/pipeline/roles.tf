data "aws_kms_key" "chamber_key" {
  key_id = var.chamber_key
}

/**
 * Plan role
 */
resource "aws_iam_role" "plan" {
  name               = "Codebuild${var.name}Plan"
  path               = "/service-role/"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy" "plan_chamber_access" {
  policy = data.aws_iam_policy_document.access_chamber_params.json
  role   = aws_iam_role.plan.id
}

resource "aws_iam_role_policy" "plan_logging" {
  policy = data.aws_iam_policy_document.logging.json
  role   = aws_iam_role.plan.id
}

resource "aws_iam_role_policy" "plan_ecr" {
  policy = data.aws_iam_policy_document.ecr.json
  role   = aws_iam_role.plan.id
}

resource "aws_iam_role_policy_attachment" "plan_ro" {
  role       = aws_iam_role.plan.id
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

/**
 * Apply role
 */
resource "aws_iam_role" "apply" {
  name               = "Codebuild${var.name}Apply"
  path               = "/service-role/"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy" "apply_chamber_access" {
  policy = data.aws_iam_policy_document.access_chamber_params.json
  role   = aws_iam_role.apply.id
}

resource "aws_iam_role_policy" "apply_logging" {
  policy = data.aws_iam_policy_document.logging.json
  role   = aws_iam_role.apply.id
}

resource "aws_iam_role_policy" "apply_ecr" {
  policy = data.aws_iam_policy_document.ecr.json
  role   = aws_iam_role.apply.id
}

resource "aws_iam_role_policy_attachment" "apply_admin" {
  role       = aws_iam_role.apply.id
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "access_chamber_params" {
  statement {
    actions = [
      "kms:ListKeys",
      "kms:ListAliases",
      "kms:Describe*",
    ]
    resources = ["*"]
  }
  statement {
    actions = [
      "kms:Decrypt",
    ]
    resources = [
      data.aws_kms_key.chamber_key.arn,
    ]
  }
  statement {
    actions = [
      "ssm:GetParameters",
    ]
    resources = [
      "arn:aws:ssm:*:${local.account_id}:parameter/${local.secrets_namespace}/*",
      "arn:aws:ssm:${local.region}:${local.account_id}:parameter/infrastructure/ci-decryption",
    ]
  }
}

data "aws_iam_policy_document" "logging" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    effect = "Allow"
    resources = [
      "arn:aws:logs:*:*:log-group:/aws/codebuild/${var.name}*:*",
    ]
  }
}

data "aws_iam_policy_document" "ecr" {
  statement {
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
    ]
    effect = "Allow"
    resources = [
      "*",
    ]
  }
}

