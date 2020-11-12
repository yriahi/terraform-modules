variable "name" {
  type        = "string"
  description = "The name to apply to the instance and autoscaling group"
}

variable "ami" {
  type        = "string"
  description = "The AMI ID to use for the instances. Keep this at the default value to automatically receive AMI updates to Amazon Linux 2"
  // AMI Built from packer/base.json
  default     = "ami-0cbd337c6406bd65b"
}

variable "capacity" {
  type        = "string"
  description = "The number of instances to launch."
  default     = 1
}

variable "instance_type" {
  type        = "string"
  description = "The instance type to use (eg: t3.nano)"
  default     = "t3.nano"
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

variable "security_groups" {
  type        = "list"
  description = "Security groups to apply to the instances."
  default     = []
}

variable "policies" {
  type        = "list"
  description = "IAM Policies to attach to the instances."
  default     = []
}

variable "user_data" {
  type        = "string"
  description = "Base 64 encoded user data to run on instances at creation time"
  default     = ""
}

variable "subnets" {
  type        = "list"
  description = "Subnets to launch instances into"
  default     = []
}

variable "keypair" {
  type        = "string"
  description = "The name of an SSH keypair to attach to all instances."
}

variable "target_group_arns" {
  type = "list"
  description = "A list of target group ARNs to pass to the ASG. See https://www.terraform.io/docs/providers/aws/r/autoscaling_group.html#target_group_arns"
  default = []
}

variable "load_balancers" {
  type = "list"
  description = "A list of load balancers to pass to the ASG. See https://www.terraform.io/docs/providers/aws/r/autoscaling_group.html#load_balancers"
  default = []
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
  description = "The value to use for the instance scheduling tag (schedulev2). Defaults to `na` for ASG instances, because ASGs should be scheduled via the ASG scheduler."
  default = "na"
}

variable "instance_backup" {
  type        = "string"
  description = "Backup instructions for EC2 instances"
  default = "na"
}

variable "instance_patch_group" {
  type        = "string"
  description = "Patch group to apply to EC2 instances."
}

variable "tags" {
  type        = "map"
  description = "Additional tags to apply to all instances."
  default     = {}
}
