
variable "region" {
  type = "string"
  description = "The AWS region to scope access to (defaults to current region)."
  default = ""
}

variable "account_id" {
  type = "string"
  description = "The AWS account ID to scope access to (defaults to current account)."
  default = ""
}

variable "application" {
  type = "string"
  description = "The application tag to limit access to."
}

variable "environment" {
  type = "string"
  description = "The environment tag to limit access to."
}
