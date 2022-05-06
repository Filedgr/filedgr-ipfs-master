locals {
  originId = "elb-origin"
}

#data "aws_acm_certificate" "my_cert" {
#  domain   = "dev.filedgr.com"
#  statuses = ["ISSUED"]
#}

resource "aws_cloudfront_distribution" "ipfs-cloudfront" {
  origin {
    domain_name = var.elbDomain
    origin_id   = var.elbDomain
    connection_attempts = 3
    connection_timeout = 10

    custom_header {
      name  = "X-Forwarded-Host"
      value = "ipfs2.dev.filedgr.com"
    }

    custom_header {
      name  = "X-Forwarded-Proto"
      value = "https"
    }

    origin_shield {
      enabled              = false
      origin_shield_region = "eu-central-1"
    }

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]

      origin_read_timeout = 10
      origin_keepalive_timeout = 60
    }
  }

  aliases = ["ipfs2.dev.filedgr.com"]
  enabled = true

  default_cache_behavior {
    compress = true
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["HEAD", "GET"]
    cached_methods         = ["HEAD", "GET"]
    target_origin_id       = var.elbDomain

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

#    cache_policy_id = ""
#    origin_request_policy_id = ""
  }
  restrictions {
    geo_restriction {
      restriction_type = "blacklist"
      locations = ["RU"]
    }
  }
  viewer_certificate {
    acm_certificate_arn = "arn:aws:acm:us-east-1:867912683733:certificate/3241bf4d-f058-42ae-b2bf-1671bd64f2d3"
    ssl_support_method = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}