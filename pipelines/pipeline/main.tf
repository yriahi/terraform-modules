data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
locals {
  region = "${coalesce(var.region, data.aws_region.current.name)}"
  account_id = "${coalesce(var.account_id, data.aws_caller_identity.current.account_id)}"
  secrets_namespace = "tf/${var.namespace}"
}

resource "aws_codebuild_project" "plan" {
  name = "${var.name}-plan"
  artifacts {
    type = "NO_ARTIFACTS"
  }
  cache {
    type  = "LOCAL"
    modes = ["LOCAL_DOCKER_LAYER_CACHE", "LOCAL_SOURCE_CACHE", "LOCAL_CUSTOM_CACHE"]
  }
  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = var.build_image
    type         = "LINUX_CONTAINER"

    # Use privileged mode to allow Docker images to be built.
    privileged_mode = true
    environment_variable {
      name  = "CHAMBER_KMS_KEY_ALIAS"
      value = var.chamber_key
    }
    environment_variable {
      name  = "CHAMBER_NAMESPACE"
      value = local.secrets_namespace
    }
  }
  service_role = aws_iam_role.plan.arn
  source {
    type                = "GITHUB"
    location            = var.repository
    git_clone_depth     = "1"
    report_build_status = true
    buildspec           = ".pipeline/plan.yml"
    auth {
      type     = "OAUTH"
      resource = var.oauth_token
    }
  }
  tags = merge(
    var.tags,
    {
      "Name" = "${var.name}-plan"
    },
  )
}

resource "aws_codebuild_webhook" "plan" {
  project_name  = aws_codebuild_project.plan.name
  branch_filter = "^(?!master|develop).*$"
}

resource "aws_codebuild_webhook" "apply_develop" {
  project_name  = aws_codebuild_project.apply_develop.name
  branch_filter = "^develop$"

  // We use a provisioner here to remove the pull_request event from the apply
  // webhook.  Otherwise, this codebuild job will run for every PR.
  // We use a provisioner here to remove the pull_request event from the apply
  // webhook.  Otherwise, this codebuild job will run for every PR.
  provisioner "local-exec" {
    command = "${path.module}/src/disable-webhook-pr.sh \"${aws_codebuild_webhook.apply_develop.url}\" \"${var.oauth_token}\""
  }
}

resource "aws_codebuild_project" "apply_develop" {
  name = "${var.name}-applydev"
  artifacts {
    type = "NO_ARTIFACTS"
  }
  cache {
    type  = "LOCAL"
    modes = ["LOCAL_DOCKER_LAYER_CACHE", "LOCAL_SOURCE_CACHE"]
  }
  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = var.build_image
    type         = "LINUX_CONTAINER"

    # Use privileged mode to allow the creation of Docker images.
    privileged_mode = true
    environment_variable {
      name  = "CHAMBER_KMS_KEY_ALIAS"
      value = var.chamber_key
    }
    environment_variable {
      name  = "CHAMBER_NAMESPACE"
      value = local.secrets_namespace
    }
    environment_variable {
      name  = "BRANCH"
      value = "develop"
    }
  }
  service_role = aws_iam_role.apply.arn
  source {
    type                = "GITHUB"
    location            = var.repository
    git_clone_depth     = "1"
    report_build_status = true
    buildspec           = ".pipeline/apply.yml"
    auth {
      type     = "OAUTH"
      resource = var.oauth_token
    }
  }
  tags = merge(
    var.tags,
    {
      "Name" = "${var.name}-applydev"
    },
  )
}

resource "aws_codebuild_webhook" "apply_master" {
  project_name  = aws_codebuild_project.apply_master.name
  branch_filter = "^master$"

  // We use a provisioner here to remove the pull_request event from the apply
  // webhook.  Otherwise, this codebuild job will run for every PR.
  // We use a provisioner here to remove the pull_request event from the apply
  // webhook.  Otherwise, this codebuild job will run for every PR.
  provisioner "local-exec" {
    command = "${path.module}/src/disable-webhook-pr.sh \"${aws_codebuild_webhook.apply_master.url}\" \"${var.oauth_token}\""
  }
}

resource "aws_codebuild_project" "apply_master" {
  name = "${var.name}-applymas"
  artifacts {
    type = "NO_ARTIFACTS"
  }
  cache {
    type  = "LOCAL"
    modes = ["LOCAL_DOCKER_LAYER_CACHE", "LOCAL_SOURCE_CACHE"]
  }
  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = var.build_image
    type         = "LINUX_CONTAINER"

    # Use privileged mode to allow the creation of Docker images.
    privileged_mode = true
    environment_variable {
      name  = "CHAMBER_KMS_KEY_ALIAS"
      value = var.chamber_key
    }
    environment_variable {
      name  = "CHAMBER_NAMESPACE"
      value = local.secrets_namespace
    }
    environment_variable {
      name  = "BRANCH"
      value = "master"
    }
  }
  service_role = aws_iam_role.apply.arn
  source {
    type                = "GITHUB"
    location            = var.repository
    git_clone_depth     = "1"
    report_build_status = true
    buildspec           = ".pipeline/apply.yml"
    auth {
      type     = "OAUTH"
      resource = var.oauth_token
    }
  }
  tags = merge(
    var.tags,
    {
      "Name" = "${var.name}-applymas"
    },
  )
}

resource "aws_cloudwatch_event_rule" "build_failure" {
  name          = "${var.name}-failures"
  description   = "Sends events on failures"
  event_pattern = <<EOD
{
  "source": ["aws.codebuild"],
  "detail-type": ["CodeBuild Build State Change"],
  "detail": {
    "build-status": ["FAILED"],
    "project-name": [
      "${aws_codebuild_project.apply_develop.name}",
      "${aws_codebuild_project.apply_master.name}"
    ]
  }
}
EOD

}

resource "aws_cloudwatch_event_target" "build_failure" {
  count = length(var.failure_topics)
  arn = element(var.failure_topics, count.index)
  rule = aws_cloudwatch_event_rule.build_failure.name
  target_id = "${var.name}-to-SNS"
  input_transformer {
    input_template = jsonencode("Codebuild job failed for <project-name>")
    input_paths = {
      "project-name" = "$.detail.project-name"
      "build-id" = "$.id"
    }
  }
}

