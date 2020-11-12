output "domain_name" {
  value = "${var.domain_name}"
}

output "certificate_arn" {
  value = "${aws_acm_certificate_validation.default.certificate_arn}"
}
