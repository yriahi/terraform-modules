
data "aws_iam_policy_document" "deployment" {
  statement {
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
    ]
    resources = ["${aws_s3_bucket.site.arn}/*"]
  }
  statement {
    actions = [
      "s3:ListBucket"
    ]
    resources = [aws_s3_bucket.site.arn]
  }
  statement {
    actions = [
      "cloudfront:CreateInvalidation",
      "cloudfront:GetInvalidation",
      "cloudfront:ListInvalidations"
    ]
    resources = aws_cloudfront_distribution.domain_distribution.*.arn
  }
}

resource "aws_iam_group" "deployment" {
  count = var.create_deployment_group ? 1 : 0
  name = "${var.name}-deployment"
}
resource "aws_iam_group_policy" "deployment" {
  count = var.create_deployment_group ? 1 : 0
  group = "${aws_iam_group.deployment[0].name}"
  policy = "${data.aws_iam_policy_document.deployment.json}"
}
