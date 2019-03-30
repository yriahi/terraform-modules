# useful if you have a naming convention for naming your resources.
variable "name_prefix" {
  type = "string"
  description = "The name prefix to use for all created resources."
}

# resource tagging
variable "tags" {
  type = "map"
  description = "A map of tags to apply to created resources."
  default = {}
}
