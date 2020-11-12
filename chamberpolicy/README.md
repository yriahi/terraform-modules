Chamber Policy
==============

This Terraform module renders IAM policies for reading or writing secrets stored with [Chamber](https://github.com/segmentio/chamber).

It does not create any resources on its own - it only provides outputs for IAM policies that can be attached to IAM users, roles, or groups.

Usage:

```hcl-terraform

# Invoke the module to formulate read and write policies
# for a particular namespace.
module "chamber_policy" {
  source = "github.com/massgov/mds-terraform-common//chamberpolicy?ref=REPLACE_WITH_LATEST_VERSION"
  namespace = "apps/mds-etl/nonprod"
}

# Attach a read only policy to a reader role.
resource "aws_iam_role_policy" "chamber_read_attachment" {
  role = "${aws_iam_role.reader.id}"
  policy = "${chamber_policy.read_policy}"
}

# Attach a read/write policy to a "writer" role.
resource "aws_iam_role_policy" "chamber_write_attachment" {
  role = "${aws_iam_role.writer.id}"
  policy = "${chamber_policy.readwrite_policy}"
}
```
