Changelog
=========

## [Unreleased]

## [0.23.0] - 2019-06-17

### Changed
- [ASG] Rebuilt AMI for updated version of SSM agent, Amazon Linux 2
- [ECS Cluster] Rebuilt AMI for updated version of SSM agent, Amazon Linux 2, ECS Agent.

## [0.22.0] - 2019-06-11

### Added
- [Developer Policy] Added developer policy module to manage developer level access to resources that can be controlled with tags.
- [Lambda] Added developer policy output for allowing developers to manipulate the function.

## [0.21.0] - 2019-05-31

### Changed
- [RDS Instance] Use performance insights 

## [0.20.0] - 2019-05-13

### Added
- [Chamber Policy] Added a chamber policy generation module to automatically build secure read and read/write IAM policies for chamber namespaces.

## [0.19.0] - 2019-04-17
### Changed
- [Lambda] Use human readable names for Cloudwatch alarm name/description.

## [0.18.1] - 2019-03-28
### Fixed
- [Static] Add `Name` tag to the S3 bucket being used for the static site.

## [0.18.0] - 2019-03-28
### Fixed
- [Static] Apply tags to created S3 bucket.
### Changed
- [ECS Cluster, ASG] Allow specification of EBS volume properties (as long as the AMI you're using uses /dev/xvda as the root volume).
- [RDS Instance] Allow specification of a parameter group.

## [0.17.0] - 2019-03-22
### Fixed
- [Static] Add unique `origin_id` variable to enable CloudFront distribution provisioning.
### Changed
- [Static] Switch cloudfront distribution to use `aws_s3_bucket.bucket_regional_domain_name` instead of `aws_s3_bucket.website_endpoint`

## [0.16.0] - 2019-03-04
### Changed
- [ECS Cluster] Use AMI that trusts BLESS keys by default. This can be overridden.
- [ASG] Use AMI that trusts BLESS keys by default. This can be overridden.

## [0.15.0] - 2019-03-04
### Changed
- [RDS Instance] Only specify minor engine version to allow for point version updates.

## [0.13.0] - 2019-02-20
### Added
- [ASG] Add `target_group_arns` and `load_balancers` properties to ASG module to support NLB usage.

## [0.11.0] - 2019-02-01
### BREAKING
- [Lambda] Remove `environment_variables` option.  It's been replaced by `environment`.
### Added
- [Lambda] Add `environment` option for lambda.  This is the new way to specify environment variables for a Lambda function.  The old way would not allow us to have no environment variables (required for Lambda@Edge).
### Changed
- [Lambda] Allow lambda@edge to assume the created Lambda role.
- [Lambda] Use function versioning.

## [0.10.0] - 2019-01-30
### Fixed
- [Lambda] Fix an error that was causing the lambda module to fail when invoked with an empty schedule ({}).

## [0.9.0] - 2018-12-13
### Changed
- [RDS Instance] Set sane defaults for the maintenance window, snapshot tagging, and deletion protection.
- [RDS Instance] Allow storage to be optionally encrypted.

## [0.8.0] - 2018-12-12
### Added
- [ECS Cluster] Add `schedule`, `schedule_down` and `schedule_up` properties, which control instance scheduling using the ASG scheduler.  Until we receive a config exception from EOTSS, these should be used in addition to the `schedulev2` tag (`instance_schedule` property).  Once the exception is granted, we should use `na` for the `schedulev2` tag, and exclusively use the ASG scheduling for all ASG instances.

## [0.7.0] - 2018-12-11
### Added
- [ASG] Add `schedule`, `schedule_down` and `schedule_up` properties, which control instance scheduling using the ASG scheduler.  Until we receive a config exception from EOTSS, these should be used in addition to the `schedulev2` tag (`instance_schedule` property).  Once the exception is granted, we should use `na` for the `schedulev2` tag, and exclusively use the ASG scheduling for all ASG instances.

## [0.6.0] - 2018-12-10
### Added
- [RDS Instance] Added RDS instance module to instantiate a single RDS instance (not appropriate for Aurora).

## [0.5.0] - 2018-12-05
### Added
- [Static] Static site module to manage an S3 static site that is only accessible via Cloudfront.

### Changed
- [ECS Cluster] Bump AMI to latest Amazon Linux 2 ECS Optimized + SSM
- [ASG] Bump AMI to latest Amazon Linux 2

## [0.4.0] - 2018-11-26
### Changed
- [Lambda] Create log group as part of Lambda module so we are able to specify the retention policy.  Note: This will require that existing log groups are deleted or imported (using `terraform import`) before applying.

## [0.3.0] - 2018-11-19
### Changed
- [ASG] Update to schedulerv2 tags to support EOTSS requirements.

## [0.2.0] - 2018-10-31
### Added
- [Lambda] Add outputs for `function_name` and `function_arn`.
- [Lambda] Add option SNS alerts on Lambda error by passing in SNS topic ARNs to `error_topics`.

## [0.1.0] - 2018-10-30
### Changed
- [ECS Cluster] Update to Amazon 2 ECS optimized AMI.
- [ECS Cluster] Use custom AMI based on Amazon 2 ECS optimized that includes SSM.
