resource "aws_acm_certificate" "default" {
  domain_name       = "${var.domain_name}"
  validation_method = "DNS"

  tags = "${merge(var.tags, map(
      "Name", "Certificate for ${var.domain_name}"
  ))}"
}

resource "aws_acm_certificate_validation" "default" {
  certificate_arn         = "${aws_acm_certificate.default.arn}"
  validation_record_fqdns = ["${aws_route53_record.validation.fqdn}"]
}

data "aws_route53_zone" "tld" {
  name = "${var.zone}"
}

resource "aws_route53_record" "validation" {
  name    = "${aws_acm_certificate.default.domain_validation_options.0.resource_record_name}"
  type    = "${aws_acm_certificate.default.domain_validation_options.0.resource_record_type}"
  zone_id = "${data.aws_route53_zone.tld.zone_id}"
  records = ["${aws_acm_certificate.default.domain_validation_options.0.resource_record_value}"]
  ttl     = "60"
}

resource "aws_route53_record" "domain" {
  name    = "${var.domain_name}"
  type    = "CNAME"
  zone_id = "${data.aws_route53_zone.tld.zone_id}"
  records = ["${aws_cloudfront_distribution.dashboards.domain_name}"]
  ttl     = "${var.dns_ttl}"
}

/**
 * Health Check
 */
resource "aws_route53_health_check" "domain" {
  count             = "${var.health_check_path == "" ? 0 : 1}"
  type              = "HTTPS"
  fqdn              = "${var.domain_name}"
  port              = 443
  resource_path     = "${var.health_check_path}"
  failure_threshold = "2"
  request_interval  = "30"

  tags = "${merge(var.tags, map(
      "Name", "Health check for ${var.domain_name}"
  ))}"
}

resource "aws_cloudwatch_metric_alarm" "domain_watch" {
  count               = "${var.notification_topic == "" ? 0 : 1}"
  alarm_name          = "${var.name}_domain_health"
  namespace           = "AWS/Route53"
  metric_name         = "HealthCheckStatus"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  period              = "60"
  statistic           = "Minimum"
  threshold           = "1"
  unit                = "None"

  dimensions = {
    HealthCheckId = "${aws_route53_health_check.domain.id}"
  }

  alarm_description         = "Monitors uptime of domain."
  alarm_actions             = ["${var.notification_topic}"]
  insufficient_data_actions = ["${var.notification_topic}"]
  treat_missing_data        = "breaching"
}

resource "aws_cloudfront_distribution" "dashboards" {
  enabled         = true
  aliases         = ["${var.domain_name}"]
  is_ipv6_enabled = true
  comment         = "${var.comment}"

  origin {
    domain_name = "${var.origin}"
    origin_id   = "balancer"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "${var.origin_policy}"
      origin_ssl_protocols   = ["TLSv1.1"]
      origin_read_timeout    = "60"
    }

    custom_header {
      name  = "CDN-FWD"
      value = "${var.cdn_token}"
    }
  }

  default_cache_behavior {
    target_origin_id       = "balancer"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]

    forwarded_values {
      query_string = true
      headers      = ["Host"]

      cookies {
        forward = "all"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  viewer_certificate {
    acm_certificate_arn      = "${aws_acm_certificate_validation.default.certificate_arn}"
    minimum_protocol_version = "TLSv1"
    ssl_support_method       = "sni-only"
  }

  tags = "${var.tags}"
}
