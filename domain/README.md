Cloudfront Domain
=================

This Terraform module defines a public domain secured by SSL, hosted on Cloudfront.  

Health Checks
-------------

This module can set up a Route 53 domain health check to a path of your choosing.  SNS notifications are sent to the topic designated by `notification_topic`.

Security
--------

This module can add a CDN-FWD header of your choosing, which can be validated at the origin to ensure that requests are originating from Cloudfront.