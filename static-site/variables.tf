// aws region
provider "aws" {
  region = "us-east-1"
}

// dns zone
variable "zone_id" {
  type        = "string"
  description = "The zone that domain will be added to."
}

// site name being added
variable "domain_name" {
  type        = "string"
  description = "The full domain name being added."
}

// new site origin id
variable "origin_id" {
  type        = "string"
  description = "Unique identifier for the CloudFront domain"
  default = "default"
}

// error document
variable "error_document" {
  default = "/404.html"
  description = "The error document being used for errors."
}

// tags
variable "tags" {
  type    = "map"
  default = {}
}
