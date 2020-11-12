variable "name" {
  type = "string"
}

variable "tags" {
  type        = "map"
  description = "A map of tags to use for created resources"
  default     = {}
}

variable "vpc" {
  type = "string"
}

variable "subnets" {
  type = "list"
}

variable "instance_type" {
  type        = "string"
  description = "The instance type to launch."
}

variable "capacity" {
  type        = "string"
  description = "The number of instances to launch."
  default     = "1"
}

variable "keypair" {
  type        = "string"
  description = "The name of the SSH keypair to attach to the instances."
}

variable "security_groups" {
  type        = "list"
  description = "Security groups to attach to the instances."
  default     = []
}

variable "volume_size" {
  type = "string"
  description = "The EBS volume size to use for the root EBS volume"
  default = 30
}

variable "volume_encryption" {
  type = "string"
  description = "A boolean indicating whether to encrypt the root EBS volume or not."
  default = false
}

variable "schedule" {
  type = "string"
  description = "A boolean indicating whether to automatically schedule the ASG according to the `schedule_down` and `schedule_up` variables."
  default = false
}

variable "schedule_down" {
  type = "string"
  description = "A cron expression indicating when to schedule the ASG to scale down to 0 instances (defaults to 7PM EST weekdays)."
  default = "59 23 * * 1-5"
}

variable "schedule_up" {
  type = "string"
  description = "A cron expression indicating when to schedule the ASG to scale up to $capacity instances (defaults to 7AM EST weekdays)"
  default = "00 12 * * 1-5"
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

variable "ami" {
  type = "string"
  description = "AMI to use for cluster instances."
  // Custom AMI based on AWS Linux 2 ECS optimized
  // Also has SSM.  See packer build (/packer/ecs_ssm.json)
  default = "ami-08d6a38d714da30db"
}
