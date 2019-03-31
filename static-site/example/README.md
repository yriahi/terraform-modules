
This example leverages my Terraform static site module to create the needed infrastructure for hosting a static site on S3. These are the AWS services that it will make use of:
- Route 53
- S3
- Cloudfront
- IAM

## Requirements:
- [Terraform](https://learn.hashicorp.com/terraform/getting-started/install.html)
- AWS Account.
- Configured AWS profile.
- A hosted DNS zone on Route 53 (Zone ID).

## Steps:
- Add your AWS hosted zone ID to `static-site/example/variables.tf`
- Copy `example` folder to your new or existing static site project folder.
- Rename the `example` folder to `terraform` (not required, good to stick to convention).
- Run the following commands:
```
$ cd terraform
$ terraform init
```

Preview and deploy your non-production infrastructure version:
```
$ terraform plan -var-file="vars.dev.tfvars"  #preview your changes to dev
$ terraform apply -var-file="vars.dev.tfvars" #apply your changes to dev
```

Preview and deploy your production infrastructure version:
```
$ terraform plan -var-file="vars.dev.tfvars"  #preview your changes to prod
$ terraform apply -var-file="vars.dev.tfvars" #apply your changes to prod
```

Note: Cloudfront will take few minutes to deploy.
