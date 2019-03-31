
# used to prefix resource names for identification
variable "name_prefix" {
  type = "string"
  description = "The name prefix to use for all created resources."
}

# Route 53 DNS zone
variable "zone_id" {
  type = "string"
  description = "The Route 53 DNS zone to use."
  default = "<AWS_HOSTED_DNS_ZONEID_HERE>"
}

# domain will vary between prod and non-prod
variable "domain_name" {
  type = "string"
  description = "The domain name of the static site."
}

variable "origin_id" {
  type = "string"
  description = "A unique identifier for the origin to use with Cloudfront."
}

# tags defined in tfvars files
# only one that comes by default with the module is "Name"
variable "tags" {
  type = "map"
  description = "A map of tags to apply to created resources."
  default = {}
}
