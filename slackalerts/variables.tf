variable "name" {
  type        = string
  description = "A descriptive name to use for created resources"
}

variable "SLACK_TOKEN" {
  type        = string
  description = "Slack authentication token"
}

variable "default_channel" {
  type        = string
  description = "The channel to send notifications to if no other channel is specified"
}

variable "sns_topics" {
  type        = list(string)
  description = "SNS Topics to subscribe to for alerts"
  default     = []
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "sns_topic_count" {
  type        = string
  description = "Count of SNS topics to subscribe to (works around TF bug using count on calculated lists)"
}

variable "topic_map" {
  description = "SNS topics mapped to Slack channels."
  type = list(object({
    topic_arn = string
    channel = string
    username = string
    icon_emoji = string
  }))
  default = []
}
