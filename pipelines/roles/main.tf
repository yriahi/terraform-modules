/**
 * IAM Role for the "plan" codebuild job.
 *
 * This role needs read permissions on nearly everything.
 */
resource "aws_iam_role" "codebuild_plan" {
  name               = "TerraformCodePipelinePlan"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume.json
  path               = "/service-role/"
}

resource "aws_iam_role_policy" "codebuild_plan" {
  role   = aws_iam_role.codebuild_plan.id
  policy = data.aws_iam_policy_document.codebuild_plan.json
}

resource "aws_iam_role_policy_attachment" "codebuild_plan_readonly" {
  role       = aws_iam_role.codebuild_plan.id
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

data "aws_iam_policy_document" "codebuild_assume" {
  statement {
    sid = ""

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
    effect = "Allow"
  }
}

data "aws_iam_policy_document" "codebuild_plan" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    effect = "Allow"
    resources = [
      "*",
    ]
  }
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

/**
 * IAM Role to execute the plan with.
 *
 * This role needs admin level permissions.
 */
resource "aws_iam_role" "codebuild_apply" {
  name               = "TerraformCodePipelineApply"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume.json
  path               = "/service-role/"
}

resource "aws_iam_role_policy_attachment" "codebuild_apply_admin" {
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role       = aws_iam_role.codebuild_apply.id
}

