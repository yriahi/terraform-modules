This modules builds the components needed to host a a static site on AWS. It does the following:
- Creates an S3 bucket and prepares it for static content hosting.
- Adds a Cloudfront distribution.
- Sets the IAM policy.
- Provisions an ACM certificate with DNS validation.

As a Terraform module, this is meant to be instantiated. See the README.md in the example folder.
