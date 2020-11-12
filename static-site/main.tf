locals {
  domains = [
    for environment in var.environments:
          environment.domain
  ]
  primary_domain = local.domains[0]
  alternate_domains = slice(local.domains, 1, length(local.domains))
}

// S3
// Site bucket
resource "aws_s3_bucket" "site" {
  // name bucket after domain name
  bucket = var.bucket_name

  website {
    index_document = var.index_document
    error_document = coalesce(var.error_document, var.index_document)
  }

  // Enable CORS if requested.
  dynamic "cors_rule" {
    for_each = var.enable_cors ? [1] : []

    content {
      allowed_headers = var.cors_allowed_headers
      allowed_methods = var.cors_allowed_methods
      allowed_origins = var.cors_allowed_origins
      expose_headers  = ["ETag"]
      max_age_seconds = 3600
    }
  }

  tags = merge(
    var.tags,
    {
      "Name"               = var.bucket_name
      "dataclassification" = "na"
      "public"             = "yes"
    }
  )
}

// IAM
// OAI (Origin Access Identity) policy document
data "aws_iam_policy_document" "oai_read" {
  dynamic "statement" {
    for_each = var.environments

    content {
      actions = ["s3:GetObject", "s3:ListBucket"]
      resources = [
        aws_s3_bucket.site.arn,
        "${aws_s3_bucket.site.arn}/${statement.value.name}/*"
      ]

      principals {
        type = "AWS"
        identifiers = [aws_cloudfront_origin_access_identity.edge[statement.key].iam_arn]
      }
    }
  }
}

// S3
// Apply policy to bucket
resource "aws_s3_bucket_policy" "default" {
  bucket = aws_s3_bucket.site.id
  policy = data.aws_iam_policy_document.oai_read.json
}

// AWS Certificate Manager
// TLS/SSL certificate for the new domain
resource "aws_acm_certificate" "default" {
  domain_name = local.primary_domain
  subject_alternative_names = local.alternate_domains
  // rely on a DNS entry for validating the certificate
  validation_method = "DNS"
  tags = merge(var.tags, {
    "Name": var.name
  })
  // Replace certificate that is currently in use
  lifecycle {
    create_before_destroy = true
  }
}

// Route 53
// dns record to use for certificate validation
// create the DNS entry in th relevant zone
resource "aws_route53_record" "verification" {
  count = length(local.domains)
  name    = aws_acm_certificate.default.domain_validation_options[count.index].resource_record_name
  type    = aws_acm_certificate.default.domain_validation_options[count.index].resource_record_type
  records = [aws_acm_certificate.default.domain_validation_options[count.index].resource_record_value]
  zone_id = var.zone_id
  ttl     = "60"
}

// Route 53
// validate the certificate with dns entry
resource "aws_acm_certificate_validation" "default" {
  certificate_arn         = aws_acm_certificate.default.arn
  validation_record_fqdns = aws_route53_record.verification.*.fqdn
}

//// Route 53
//// Add CNAME entry for domain
resource "aws_route53_record" "default" {
  count = length(var.environments)
  zone_id = var.zone_id
  name    = var.environments[count.index].domain
  type    = "CNAME"
  ttl     = "300"
  records = [aws_cloudfront_distribution.domain_distribution[count.index].domain_name]
}

// Cloudfront
// CDN for the domain
resource "aws_cloudfront_distribution" "domain_distribution" {
  count = length(var.environments)
  comment = "${var.name}:${var.environments[count.index].name}"
  wait_for_deployment = false
  enabled             = true
  default_root_object = var.index_document

  origin {
    // S3 bucket url
    domain_name = aws_s3_bucket.site.bucket_regional_domain_name

    // identifies the origin with a name (can be any string of choice)
    origin_id = "default"

    origin_path = "/${var.environments[count.index].name}"

    // since the s3 bucker is not directly accessed by the public
    // identity to access the cloudfront distro
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.edge[count.index].cloudfront_access_identity_path
    }
  }

  // If this site is an SPA, we need to serve up the index document instead of
  // a 404 so the app has a chance to do dynamic routing.
  dynamic "custom_error_response" {
    for_each = var.is_spa ? [1] : []
    content {
      error_code = 404
      response_code = 200
      response_page_path = "/${var.index_document}"
    }
  }

  default_cache_behavior {
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    allowed_methods        = var.allowed_methods
    cached_methods         = var.cached_methods
    target_origin_id       = "default"
    default_ttl = var.default_ttl

    // There is no backend processing in this case, so we can skip forwarding
    // things like query string and cookies. CORS headers are forwarded, if
    // we're using CORS for the site.
    forwarded_values {
      query_string = false
      headers = var.enable_cors ? ["Origin", "Access-Control-Request-Headers", "Access-Control-Request-Method"] : []
      cookies {
        forward = "none"
      }
    }
    dynamic "lambda_function_association" {
      for_each = var.environments[count.index].edge_lambdas

      content {
        event_type = lambda_function_association.value.event_type
        lambda_arn = lambda_function_association.value.lambda_arn
        include_body = coalesce(lambda_function_association.value.include_body, false)
      }
    }
  }

  // hit Cloudfront using the domain url
  aliases = [var.environments[count.index].domain]

  restrictions {
    geo_restriction {
      restriction_type = "none"

      // list of countries e.g. ["US", "CA", "GB", "DE"]
      locations = []
    }
  }

  // serve with cert
  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.default.arn
    minimum_protocol_version = "TLSv1.1_2016"
    ssl_support_method       = "sni-only"
  }

  tags = var.tags
}

// Create an identity allowing Cloudfront to access the origin.
resource "aws_cloudfront_origin_access_identity" "edge" {
  count = length(var.environments)
  comment = "Cloudfront ID for ${var.name}:${var.environments[count.index].name}"
}

