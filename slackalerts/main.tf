/**
 * Lambda Function:
 */
resource "aws_lambda_function" "sns_to_slack" {
  filename         = "${path.module}/dist/slackalerts.zip"
  source_code_hash = filebase64sha256("${path.module}/dist/slackalerts.zip")
  function_name    = var.name
  handler          = "index.handler"
  role             = aws_iam_role.lambda.arn
  runtime          = "nodejs8.10"
  environment {
    variables = {
      SLACK_TOKEN     = var.SLACK_TOKEN
      DEFAULT_CHANNEL = var.default_channel
      TOPIC_MAP       = jsonencode(var.topic_map)
    }
  }
  tags = merge(
    var.tags,
    {
      "Name" = var.name
    },
  )
}

resource "aws_sns_topic_subscription" "default" {
  count     = var.sns_topic_count
  endpoint  = aws_lambda_function.sns_to_slack.arn
  protocol  = "lambda"
  topic_arn = element(var.sns_topics, count.index)
}

resource "aws_lambda_permission" "sns_to_slack" {
  count         = var.sns_topic_count
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sns_to_slack.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = element(var.sns_topics, count.index)
}

resource "aws_cloudwatch_log_group" "lambda_logs" {
  name = "/aws/lambda/${aws_lambda_function.sns_to_slack.function_name}"
  tags = var.tags
}

data "aws_iam_policy_document" "lambda_policy" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["${aws_cloudwatch_log_group.lambda_logs.arn}:*"]
  }
}

data "aws_iam_policy_document" "lambda_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
    effect = "Allow"
  }
}

resource "aws_iam_role" "lambda" {
  name               = "LambdaSNSToSlack"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

resource "aws_iam_role_policy" "lambda" {
  policy = data.aws_iam_policy_document.lambda_policy.json
  role   = aws_iam_role.lambda.id
}

