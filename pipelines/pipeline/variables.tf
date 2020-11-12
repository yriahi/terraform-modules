variable "name" {
  type        = string
  description = "The name of the project (alphanumeric characters only)"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to apply to the codebuild jobs"
}

variable "repository" {
  type        = string
  description = "The github repository URL"
}

variable "oauth_token" {
  type        = string
  description = "The github OAuth token to use when authenticating to github"
}

variable "build_image" {
  type        = string
  description = "The docker image to run builds in."
}

variable "chamber_key" {
  type        = string
  description = "ARN of a KMS key that's used for encrypting chamber secrets"
}

variable "namespace" {
  type        = string
  description = "A lowercase, alphanumeric namespace that describes the application.  This will be used to isolate secrets."
}

variable "failure_topics" {
  type        = list(string)
  description = "A list of SNS topics to publish to on build failure"
}

