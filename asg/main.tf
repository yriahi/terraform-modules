resource "aws_launch_template" "default" {
  lifecycle {
    create_before_destroy = true
  }

  name_prefix            = "${var.name}"
  image_id               = "${var.ami}"
  instance_type          = "${var.instance_type}"
  vpc_security_group_ids = ["${var.security_groups}"]
  key_name               = "${var.keypair}"
  user_data              = "${var.user_data}"

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = "${var.volume_size}"
      volume_type = "gp2"
      delete_on_termination = "true"
      encrypted = "${var.volume_encryption}"
    }
  }

  credit_specification {
    cpu_credits = "standard"
  }

  iam_instance_profile {
    arn = "${aws_iam_instance_profile.instance.arn}"
  }

  tag_specifications {
    resource_type = "instance"

    tags = "${merge(var.tags, map(
      "schedulev2", "${var.instance_schedule}",
      "Patch Group", "${var.instance_patch_group}",
      "backup", "${var.instance_backup}"
    ))}"
  }

  tag_specifications {
    resource_type = "volume"

    tags = "${merge(var.tags, map(
      "schedulev2", "${var.instance_schedule}",
      "Patch Group", "${var.instance_patch_group}",
      "backup", "${var.instance_backup}"
    ))}"
  }
}

resource "aws_autoscaling_group" "default" {
  lifecycle {
    create_before_destroy = true
  }

  name                = "${var.name}"
  max_size            = "${var.capacity}"
  min_size            = "${var.capacity}"
  desired_capacity    = "${var.capacity}"
  vpc_zone_identifier = ["${var.subnets}"]
  target_group_arns = ["${var.target_group_arns}"]
  load_balancers = ["${var.load_balancers}"]

  launch_template {
    id      = "${aws_launch_template.default.id}"
    version = "$$Latest"
  }

  tag {
    key                 = "Name"
    propagate_at_launch = false
    value               = "${var.name}"
  }
}

resource "aws_autoscaling_schedule" "schedule_down" {
  count = "${var.schedule && var.schedule_down != "" ? 1 : 0}"
  autoscaling_group_name = "${aws_autoscaling_group.default.name}"
  scheduled_action_name = "schedule_down"
  recurrence = "${var.schedule_down}"
  min_size = 0
  max_size = 0
  desired_capacity = 0
}

resource "aws_autoscaling_schedule" "schedule_up" {
  count = "${var.schedule && var.schedule_up != "" ? 1 : 0}"
  autoscaling_group_name = "${aws_autoscaling_group.default.name}"
  scheduled_action_name = "schedule_up"
  recurrence = "${var.schedule_up}"
  min_size = "${var.capacity}"
  max_size = "${var.capacity}"
  desired_capacity = "${var.capacity}"
}
