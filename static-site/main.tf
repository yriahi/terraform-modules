// S3
// Site bucket
resource "aws_s3_bucket" "site" {
  // name bucket after domain name
  bucket = "${var.domain_name}"

  website {
    index_document = "index.html"
    error_document = "${var.error_document}"
  }
}

// IAM
// OAI (Origin Access Identity) policy document
data "aws_iam_policy_document" "oai_read" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.site.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.edge.iam_arn}"]
    }
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = ["${aws_s3_bucket.site.arn}"]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.edge.iam_arn}"]
    }
  }
}

// S3
// Apply policy to bucket
resource "aws_s3_bucket_policy" "default" {
  bucket = "${aws_s3_bucket.site.id}"
  policy = "${data.aws_iam_policy_document.oai_read.json}"
}

// AWS Certificate Manager
// TLS/SSL certificate for the new domain
resource "aws_acm_certificate" "default" {
  domain_name = "${var.domain_name}"

  // rely on a DNS entry for validating the certificate
  validation_method = "DNS"
}

// Route 53
// dns record to use for certificate validation
// create the DNS entry in th relevant zone
resource "aws_route53_record" "verification" {
  name    = "${aws_acm_certificate.default.domain_validation_options.0.resource_record_name}"
  type    = "${aws_acm_certificate.default.domain_validation_options.0.resource_record_type}"
  zone_id = "${var.zone_id}"
  records = ["${aws_acm_certificate.default.domain_validation_options.0.resource_record_value}"]
  ttl     = "60"
}

// Route 53
// Validate the certificate with dns entry
resource "aws_acm_certificate_validation" "default" {
  certificate_arn         = "${aws_acm_certificate.default.arn}"
  validation_record_fqdns = ["${aws_route53_record.verification.fqdn}"]
}

// Route 53
// Add CNAME entry for domain
resource "aws_route53_record" "default" {
  zone_id = "${var.zone_id}"
  name    = "${var.domain_name}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_cloudfront_distribution.domain_distribution.domain_name}"]
}

// Cloudfront
// cdn the domain
resource "aws_cloudfront_distribution" "domain_distribution" {
  origin {
    // S3 bucker url
    domain_name = "${aws_s3_bucket.site.bucket_regional_domain_name}"

    // identifies the origin with a name (can be any string of choice)
    origin_id = "${var.origin_id}"

    // since the s3 bucker is not directly accessed by the public
    // identity to access the cloudfront distro
    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.edge.cloudfront_access_identity_path}"
    }
  }

  enabled             = true
  default_root_object = "index.html"

  custom_error_response {
    error_code         = "404"
    response_code      = "200"
    response_page_path = "${var.error_document}"
  }

  default_cache_behavior {
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "${var.origin_id}"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400

    forwarded_values {
      query_string = true

      cookies {
        forward = "none"
      }
    }
  }

  // hit Cloudfront using the domain url
  aliases = ["${var.domain_name}"]

  restrictions {
    geo_restriction {
      restriction_type = "none"

      // list of countries e.g. ["US", "CA", "GB", "DE"]
      locations = []
    }
  }

  // serve with cert
  viewer_certificate {
    acm_certificate_arn      = "${aws_acm_certificate.default.arn}"
    minimum_protocol_version = "TLSv1"
    ssl_support_method       = "sni-only"
  }

  tags = "${var.tags}"
}

// Cloudfront
// create an identity to access origin
resource "aws_cloudfront_origin_access_identity" "edge" {
  comment = "Cloudfront ID for ${aws_s3_bucket.site.bucket}"
}
