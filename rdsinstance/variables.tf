variable "name" {
  type = "string"
}

variable "vpc" {
  type = "string"
  description = "ID of the VPC to launch instance into."
}

variable "subnets" {
  type        = "list"
  description = "Subnets to launch instance into"
  default     = []
}

variable "security_groups" {
  type        = "list"
  description = "Security groups to apply to the instances."
  default     = []
}

variable "engine" {
  type = "string"
  default = "postgres"
}

variable "engine_version" {
  type = "string"
  default = "9.6"
}

variable "parameter_group_name" {
  description = "The name of the RDS parameter group to apply to the instance"
  default = "default.postgres9.6"
}

variable "username" {
  type = "string"
  description = "The root account username."
  default = "root"
}

variable "password" {
  type = "string"
  description = "The root account password."
}

variable "policies" {
  type        = "list"
  description = "IAM Policies to attach to the instance."
  default     = []
}

variable "instance_class" {
  type = "string"
  description = "The instance type/class to use."
  default = "db.t2.micro"
}

variable "allocated_storage" {
  type = "string"
  description = "The allocated storage in GB"
  default = 10
}

variable "storage_encrypted" {
  type = "string"
  description = "Boolean indicating whether to encrypt the disk or not"
  default = false
}

variable "tags" {
  type = "map"
  description = "A map of tags to use for created resources."
  default = {}
}

variable "instance_schedule" {
  type        = "string"
  description = "The schedule on which to start and stop EC2 instances. Can be `na` or `1100;2300;utc;weekdays`, depending on whether this is a dev or prod environment."
}

variable "instance_backup" {
  type        = "string"
  description = "Backup instructions for EC2 instances"
}

variable "instance_patch_group" {
  type        = "string"
  description = "Patch group to apply to EC2 instances."
}
