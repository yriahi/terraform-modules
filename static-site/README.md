This modules builds the components needed to host a a static site on AWS. It does the following:
- Creates an S3 bucket and prepares it for static content hosting.
- Adds a Cloudfront distribution.
- Sets the IAM policy.
- Provisions an ACM certificate with DNS validation.

As a Terraform module, this is meant to be instantiated. Here is an example:

## Requirements:
- AWS Account.
- Configured AWS profile.
- Add your AWS hosted zone ID to `static-site/example/variables.tf`


```
module "my_new_cool_static_site" {
  source = "github.com/yriahi/terraform-modules//static-site?ref=0.2.0"
  domain_name = "${var.domain_name}"
  origin_id = "${var.origin_id}"
  zone_id = "${var.zone_id}"
  tags = "${merge(var.tags, map(
      ))}"
}
```
