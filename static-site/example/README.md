
This example leverages my Terraform [static site module](https://github.com/yriahi/terraform-modules/tree/develop/static-site) to create the needed infrastructure for hosting a static site on S3. These are the AWS services that it will make use of:
- Route 53
- S3
- AWS Cloudfront (Content Delivery Network)
- AWS Identity and Access Management (IAM).
- AWS Certificate Manager (ACM).

## Requirements:
- [Terraform](https://learn.hashicorp.com/terraform/getting-started/install.html).
- AWS Account.
- Configured AWS profile.
- A hosted DNS zone on Route 53 (Zone ID).

## Steps:
- Add your AWS hosted zone ID to `static-site/example/variables.tf`
- Copy `example` folder to your new or existing static site project folder.
- Rename the `example` folder to `terraform` (not required, but it is good to stick to convention here).
- Run the following commands:
```
$ cd terraform
$ terraform init
```

Preview and deploy your *non-production* infrastructure:
```
$ terraform plan -var-file="vars.dev.tfvars"  # preview your changes to dev
$ terraform apply -var-file="vars.dev.tfvars" # apply your changes to dev
```

Preview and deploy your *production* infrastructure:
```
$ terraform plan -var-file="vars.dev.tfvars"  # preview your changes to prod
$ terraform apply -var-file="vars.dev.tfvars" # apply your changes to prod
```

## Optional
- Edit the tags in the prod and non-prod files (will need `terraform apply` to deploy). Add and remove tags as you wish to meet your needs.

## Test:
- Visit the production or dev version of your static site (content of static need to be sync'd separately).

## Notes:
- Cloudfront will take few minutes to deploy.
