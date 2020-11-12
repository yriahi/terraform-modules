Developer Policy
================

This Terraform module is a generic solution for granting "developer" level access to a project's resources.  It relies on tags that are applied to the resources.  Because AWS only supports tag conditions for certain resource types, the scope of the resources this module can manage is limited.  It includes:

* **RDS**: Allows console access, and start/stop/snapshot/reboot access to a project's RDS instances, as well as Performance Insights and log access.
* **EC2**: Allows console access, and start/stop/reboot/terminate access to a project's EC2 instances.
* **SSM Session Manager**: Allows console access, and session manager access to the project's EC2 instances.
* **Cloudwatch**: Allows console access, access to ALL metrics in the account, and log access for any of the project's log streams.

Since these are the only services that allow for tag based access control, all other access has to be granted outside of this policy.

To use this policy, make sure all resources are tagged with the following two tags:

* `application`: Defines the name of the application (eg: `etl`).
* `environment`: Defines the name of the environment (eg: `dev`).

Invoking this module will create a set of policies that you can apply to a role or group.  For example, if you have a group "myapp-developers", you might use this:

```hcl-terraform
// Create the policies using the module:
module "myapp_developers_policies" {
  source = "github.com/massgov/mds-terraform-common//developerpolicy"
  application = "myapp"
  environment = "dev"
}

// Attach the policies to the group:
resource "aws_iam_group_policy" "myapp_developers_policies" {
  group = "myapp-developers"
  count = "${length(module.myapp_developers_policies.policies)}"
  policy = "${element(module.myapp_developers_policies.policies, count.index)}"
}
```