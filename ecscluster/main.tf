module "asg" {
  source        = "../asg"
  name          = "${var.name}"
  keypair       = "${var.keypair}"
  capacity      = "${var.capacity}"
  instance_type = "${var.instance_type}"
  ami           = "${var.ami}"

  security_groups = flatten([
    "${var.security_groups}",
  ])

  subnets              = "${var.subnets}"
  policies             = ["arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"]
  user_data            = "${base64encode(data.template_file.instance_init.rendered)}"
  volume_size = "${var.volume_size}"
  volume_encryption = "${var.volume_encryption}"
  instance_schedule    = "${var.instance_schedule}"
  instance_patch_group = "${var.instance_patch_group}"
  instance_backup      = "${var.instance_backup}"
  schedule = "${var.schedule}"
  schedule_down = "${var.schedule_down}"
  schedule_up = "${var.schedule_up}"

  tags = "${merge(var.tags, map(
      "Name", "${var.name}"
  ))}"
}

resource "aws_ecs_cluster" "cluster" {
  name = "${var.name}"
}

data "template_file" "instance_init" {
  template = "${file("${path.module}/src/instance_init.yml")}"

  vars {
    cluster_name = "${aws_ecs_cluster.cluster.name}"
  }
}

data "aws_iam_policy_document" "developer" {
  // @todo: There's currently no way to allow describing of services on a per-resource level.
  statement {
    effect = "Allow"
    actions = [
      "ecs:ListClusters",
      "ecs:ListServices",
      "ecs:DescribeClusters",
      "cloudwatch:GetMetricStatistics",
      // Allows scheduled task visibility
      "events:ListRuleNamesByTarget",
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "ecs:List*",
      "ecs:Describe*",
    ]
    resources = ["${aws_ecs_cluster.cluster.arn}"]
  }
  statement {
    effect = "Allow"
    actions = [
      "ecs:Describe*",
      "ecs:List*",
      "ecs:StartTask",
      "ecs:StopTask",
      "ecs:Poll",
    ]
    resources = ["*"]
    condition {
      test = "ArnEquals"
      values = ["${aws_ecs_cluster.cluster.arn}"]
      variable = "ecs:cluster"
    }
  }
}
