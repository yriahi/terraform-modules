

output "policies" {
  value = [
    "${data.aws_iam_policy_document.cloudwatch.json}",
    "${data.aws_iam_policy_document.ec2.json}",
    "${data.aws_iam_policy_document.rds.json}",
    "${data.aws_iam_policy_document.ssm.json}",
  ]
}