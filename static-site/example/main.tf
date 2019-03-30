
module "my_new_cool_static_site" {
  source = "github.com/yriahi/terraform-modules//static-site?ref=0.2.0"
  domain_name = "${var.domain_name}"
  origin_id = "${var.origin_id}"
  zone_id = "${var.zone_id}"
}
