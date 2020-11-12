
// The rendered JSON describing the read only IAM policy.
output "read_policy" {
  value = "${data.aws_iam_policy_document.read_policy.json}"
}

output "readwrite_policy" {
  value = "${data.aws_iam_policy_document.readwrite_policy.json}"
}