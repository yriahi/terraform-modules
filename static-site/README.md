This modules builds the components needed to host a a static site on AWS. It does the following:
- Creates an S3 bucket and prepares it for static content hosting.
- Adds a Cloudfront distribution.
- Sets the IAM policy.
- Provisions an ACM certificate with DNS validation.

As a Terraform module, this is meant to be instantiated. Here is an example:

```
module "my_new_cool_static_site" {
  source = "github.com/yriahi/terraform-modules//static-site?ref=0.12.0"
  domain_name = "blog.myname.me"
  origin_id = "myblog"
  zone_id = "<AWS_HOSTED_DNS_ZONEID_HERE>"
}
```
