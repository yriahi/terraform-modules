// The ID of the ASG.
output "autoscaling_group_id" {
  value = "${aws_autoscaling_group.default.id}"
}
