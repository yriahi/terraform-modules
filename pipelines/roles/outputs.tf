output "plan_role" {
  value = aws_iam_role.codebuild_plan.arn
}

output "apply_role" {
  value = aws_iam_role.codebuild_apply.arn
}

