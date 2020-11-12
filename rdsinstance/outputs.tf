
// Root username for the database.
output "username" {
  value = "${aws_db_instance.default.username}"
}

// Root password for the database.
output "password" {
  value = "${aws_db_instance.default.password}"
}

// Hostname for external connection.
output "host" {
  value = "${aws_db_instance.default.address}"
}

// Port for external connection.
output "port" {
  value = "${aws_db_instance.default.port}"
}

// Security group that is allowed to access the database.
output "accessor_security_group" {
  value = "${aws_security_group.db_accessor.id}"
}
