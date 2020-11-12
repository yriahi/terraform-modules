# Common Terraform Modules

This repository contains common Terraform modules that are used across the Massachussetts Digital Services infrastructure.

Each module should have:

* A `README.md` describing what the module does and how to use it.
* A `main.tf` file.
* A `variables.tf` file, if it takes input variables.
* An `outputs.tf` file, if it produces outputs.

Packer
------

This repository uses Packer to build custom AMIs. To rebuild an AMI:

```bash
packer build packer/ecs_ssm.json
# Packer will build the AMI and output the ID.
```

Development Workflow
--------------------

These Terraform modules are used by other Terraform code.  Development happens in the `develop` branch.  Once the code is tested and stable, use the following process to make a release:

* Merge `develop` to `master`
* Update the changelog to categorize items as being in the correct release.  Commit this change directly to `master`.
* Tag a new release using Semantic versioning (breaking changes are a major release).
* Merge `master` back to `develop`