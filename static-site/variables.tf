// aws region
provider "aws" {
  region = "us-east-1"
}

variable "name" {
  type = "string"
}

variable "bucket_name" {
  type = "string"
  default = null
}

// root domain name
variable "zone_id" {
  type        = string
  description = "The zone that domain will be added to."
}

variable "environments" {
  description = "A set of environment (dev/stage/prod) configurations. List production domain first."
  type = list(object({
    name = string
    domain = string
    edge_lambdas = list(object({
      event_type = string
      lambda_arn = string
      include_body = string
    }))
  }))
}

// error document
variable "error_document" {
  type = string
  description = "The error document being used for errors."
  default = null
}

variable "index_document" {
  type = string
  description = "The default document (usually index.html)"
  default = "index.html"
}

variable "allowed_methods" {
  type = list(string)
  description = "A list of HTTP methods that are allowed."
  default = ["GET", "HEAD", "OPTIONS"]
}

variable "cached_methods" {
  type = list(string)
  description = "A list of HTTP methods that can be cached."
  default = ["GET", "HEAD", "OPTIONS"]
}

variable "default_ttl" {
  type = string
  description = "The cache TTL that will be used if no Cache-Control headers are present."
  default = 3600
}

variable "enable_cors" {
  type = string
  default = false
}

variable "cors_allowed_methods" {
  type = list(string)
  default = ["GET", "HEAD"]
}

variable "cors_allowed_headers" {
  type = list(string)
  default = ["*"]
}

variable "cors_allowed_origins" {
  type = list(string)
  default = ["*"]
}

variable "is_spa" {
  type = string
  description = "A boolean indicating whether the site is a single page app. If it is, the index document will be used instead of a 404 response."
  default = false
}

variable "create_deployment_group" {
  type = string
  description = "A boolean indicating whether to create the IAM group for static site deployment."
  default = true
}

variable "tags" {
  type = map(string)
  default = {}
}
