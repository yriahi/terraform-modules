
// Lambda function ARN.
output "function_arn" {
  value = "${aws_lambda_function.default.arn}"
}

// Lambda function name.
output "function_name" {
  value = "${aws_lambda_function.default.function_name}"
}

// Lambda function qualified ARN (includes current version string)
output "function_qualified_arn" {
  value = "${aws_lambda_function.default.qualified_arn}"
}

// Lambda function version.
output "function_version" {
  value = "${aws_lambda_function.default.version}"
}

// Developer IAM policy.
output "developer_policies" {
  value = ["${data.aws_iam_policy_document.developer.json}"]
}