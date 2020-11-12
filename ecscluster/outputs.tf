// The ID of the ASG.
output "autoscaling_group_id" {
  value = "${module.asg.autoscaling_group_id}"
}

// ECS cluster name.
output "ecs_cluster" {
  value = "${aws_ecs_cluster.cluster.name}"
}

// Developer policies.
output "developer_policies" {
  value = ["${data.aws_iam_policy_document.developer.json}"]
}
