
resource "aws_lambda_function" "default" {
  function_name = "${var.name}"
  filename = "${var.package}"
  handler = "${var.handler}"
  role = "${aws_iam_role.default.arn}"
  source_code_hash = "${base64sha256(file("${var.package}"))}"
  runtime = "${var.runtime}"
  timeout = "${var.timeout}"
  publish = true
  vpc_config {
    security_group_ids = ["${var.security_groups}"]
    subnet_ids = ["${var.subnets}"]
  }
  # The aws_lambda_function resource has a schema for the environment
  # variable, where the only acceptable values are:
  #   a. Undefined
  #   b. An empty list
  #   c. A list containing 1 element: a map with a specific schema
  # Use slice to get option "b" or "c" depending on whether a non-empty
  # value was passed into this module.
  environment = ["${slice( list(var.environment), 0, length(var.environment) == 0 ? 0 : 1 )}"]
  tags = "${merge(var.tags, map(
      "Name", "${var.name}"
  ))}"
}

/**
 * Logging
 */
resource "aws_cloudwatch_log_group" "logs" {
  name = "/aws/lambda/${var.name}"
  retention_in_days = 30
  tags = "${merge(var.tags, map(
      "Name", "${var.name}"
  ))}"
}


/**
 * Roles/Permissioning
 */
data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com",
        "edgelambda.amazonaws.com"
      ]
    }
  }
}
resource "aws_iam_role" "default" {
  name = "${var.name}"
  assume_role_policy = "${data.aws_iam_policy_document.assume.json}"
}
resource "aws_iam_role_policy_attachment" "access_vpc" {
  role = "${aws_iam_role.default.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}
resource "aws_iam_role_policy_attachment" "additional_policies" {
  count = "${length(var.iam_policy_arns)}"
  policy_arn = "${element(var.iam_policy_arns, count.index)}"
  role = "${aws_iam_role.default.name}"
}
resource "aws_iam_role_policy" "additional_policies" {
  count = "${length(var.iam_policies)}"
  policy = "${element(var.iam_policies, count.index)}"
  role = "${aws_iam_role.default.id}"
}

/**
 * Scheduling
 */
resource "aws_cloudwatch_event_rule" "schedule" {
  count = "${length(var.schedule)}"
  name = "${var.name}-${element(keys(var.schedule), count.index)}"
  schedule_expression = "${element(values(var.schedule), count.index)}"
}
resource "aws_cloudwatch_event_target" "schedule_target" {
  count = "${aws_cloudwatch_event_rule.schedule.count}"
  arn = "${aws_lambda_function.default.arn}"
  rule = "${element(aws_cloudwatch_event_rule.schedule.*.name, count.index)}"
  target_id = "${var.name}_${count.index}"
}
resource "aws_lambda_permission" "allow_cloudwatch_to_call_lambda" {
  count = "${aws_cloudwatch_event_rule.schedule.count}"
  statement_id = "${element(aws_cloudwatch_event_rule.schedule.*.name, count.index)}"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.default.function_name}"
  principal = "events.amazonaws.com"
  source_arn = "${element(aws_cloudwatch_event_rule.schedule.*.arn, count.index)}"
}

/**
 * Alerting
 */
resource "aws_cloudwatch_metric_alarm" "alarm" {
  count = "${length(var.error_topics)}"
  alarm_name = "${coalesce(var.human_name, var.name)} error"
  alarm_description = "The Lambda function ${coalesce(var.human_name, var.name)} has errored"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = 1
  metric_name = "Errors"
  namespace = "AWS/Lambda"
  period = 60
  threshold = 1
  statistic = "Sum"
  dimensions {
    FunctionName = "${aws_lambda_function.default.function_name}"
  }
  alarm_actions             = ["${element(var.error_topics, count.index)}"]
  treat_missing_data = "notBreaching"
}

/**
 * Developer policy
 */
data "aws_iam_policy_document" "developer" {
  statement {
    effect = "Allow"
    actions = [
      "lambda:ListFunctions",
      "lambda:ListTags",
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "lambda:InvokeFunction",
      "lambda:Get*",
      "lambda:List*"
    ]
    resources = ["${aws_lambda_function.default.arn}"]
  }
  statement {
    effect = "Allow"
    actions = [
      "lambda:ListEventSourceMappings",
      "lambda:GetEventSourceMapping"
    ]
    resources = ["*"]
    condition {
      test = "ArnLike"
      values = ["${aws_lambda_function.default.arn}"]
      variable = "lambda:FunctionArn"
    }
  }
}
