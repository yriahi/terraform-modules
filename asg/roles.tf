/**
 * Instance Role - Attached to EC2 Instances in this group.
 */
resource "aws_iam_role" "instance" {
  name_prefix        = "ec2-instance-${var.name}"
  path               = "/"
  assume_role_policy = "${data.aws_iam_policy_document.instance_assume.json}"
}

resource "aws_iam_role_policy_attachment" "ssm" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
  role       = "${aws_iam_role.instance.name}"
}

/**
 * Allow additional policies to be attached to the instance as needed.
 */
resource "aws_iam_role_policy_attachment" "additional" {
  count      = "${length(var.policies)}"
  policy_arn = "${element(var.policies, count.index)}"
  role       = "${aws_iam_role.instance.name}"
}

data "aws_iam_policy_document" "instance_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_instance_profile" "instance" {
  name_prefix = "${var.name}-ec2-instance-profile"
  path        = "/"
  role        = "${aws_iam_role.instance.id}"
}
