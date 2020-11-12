variable "domain_name" {
  type        = "string"
  description = "The full domain name"
}

variable "zone" {
  type        = "string"
  description = "The domain name for the DNS zone"
}

variable "origin" {
  type        = "string"
  description = "The origin to connect back to"
}

variable "origin_policy" {
  type        = "string"
  description = "The policy to use when connecting to the origin"
}

variable "cdn_token" {
  type        = "string"
  description = "The value to add in the CDN-FWD header for all requests that pass through to the origin."
  default     = ""
}

variable "dns_ttl" {
  type    = "string"
  default = "300"
}

variable "comment" {
  type    = "string"
  default = ""
}

variable "health_check_path" {
  type        = "string"
  description = "A URL path to use for health checks on this domain."
  default     = ""
}

variable "notification_topic" {
  type        = "string"
  description = "The SNS topic ARN to notify when health checks fail."
  default     = ""
}

variable "name" {
  type = "string"
}

variable "tags" {
  type    = "map"
  default = {}
}
