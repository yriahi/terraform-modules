
resource "aws_db_subnet_group" "default" {
  name = "${var.name}-subnet"
  subnet_ids = ["${var.subnets}"]
}

// db instance
resource "aws_db_instance" "default" {
  identifier = "${var.name}"
  allocated_storage    = "${var.allocated_storage}"
  storage_type         = "gp2"
  engine               = "${var.engine}"
  engine_version       = "${var.engine_version}"
  instance_class       = "${var.instance_class}"
  username             = "${var.username}"
  password             = "${var.password}"
  backup_retention_period = 30
  copy_tags_to_snapshot = true
  deletion_protection = true
  maintenance_window = "wed:04:00-wed:05:00"
  storage_encrypted = "${var.storage_encrypted}"
  parameter_group_name = "${var.parameter_group_name}"
  db_subnet_group_name = "${aws_db_subnet_group.default.name}"
  performance_insights_enabled = true
  performance_insights_retention_period = 7
  vpc_security_group_ids = flatten([
    "${var.security_groups}",
    "${aws_security_group.db.id}"
  ])
  tags = "${merge(var.tags, map(
      "Name", "${var.name}",
      "Patch Group", "${var.instance_patch_group}",
      "schedulev2", "${var.instance_schedule}",
      "backup", "${var.instance_backup}"
  ))}"
}

// db security group
resource "aws_security_group" "db" {
  name = "${var.name}"
  vpc_id = "${var.vpc}"
  ingress {
    from_port = 5432
    protocol = "tcp"
    to_port = 5432
    security_groups = ["${aws_security_group.db_accessor.id}"]
  }
  ingress {
    from_port = 3600
    protocol = "tcp"
    to_port = 3600
    security_groups = ["${aws_security_group.db_accessor.id}"]
  }
  tags = "${merge(var.tags, map(
      "Name", "${var.name}"
  ))}"
}

// db accessor security group
resource "aws_security_group" "db_accessor" {
  name = "${var.name}-accessor"
  vpc_id = "${var.vpc}"
  tags = "${merge(var.tags, map(
      "Name", "${var.name}-accessor"
  ))}"
}

// db outgoing
resource "aws_security_group_rule" "accessor_egress_to_db_postgres" {
  from_port = 5432
  protocol = "tcp"
  to_port = 5432
  type = "egress"
  security_group_id = "${aws_security_group.db_accessor.id}"
  source_security_group_id = "${aws_security_group.db.id}"
}
resource "aws_security_group_rule" "accessor_egress_to_db_mysql" {
  from_port = 3600
  protocol = "tcp"
  to_port = 3600
  type = "egress"
  security_group_id = "${aws_security_group.db_accessor.id}"
  source_security_group_id = "${aws_security_group.db.id}"
}
