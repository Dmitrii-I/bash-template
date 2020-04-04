terraform {
  backend "remote" {
    hostname      = "app.terraform.io"
    organization  = "bash-template"

    workspaces {
      prefix = "bash-template-"
    }
  }
}

locals {
  domain_name         = "bash-template.com"
  aws_default_region  = "eu-central-1"
  website_bucket      = "bash-template.com"
  website_logs_bucket = "bash-template-site-logs"
}

provider "aws" {
  # No alias set, meaning this is the default provider for all resources.
  region              = local.aws_default_region
  profile             = "8f302fabec669d3401657e9e71b29b46"
  allowed_account_ids = [
    "173724624509"
  ]
}

provider "aws" {
  # This provider will be used to create ACM certificate in us-east-1 region
  # as required by CloudFront.
  alias               = "us-east-1"
  region              = "us-east-1"
  profile             = "8f302fabec669d3401657e9e71b29b46"
  allowed_account_ids = [
    "173724624509"
  ]
}

resource "aws_s3_bucket" "logs" {
  bucket  = local.website_logs_bucket
  acl     = "log-delivery-write"
}

data "aws_iam_policy_document" "website" {
  statement {
    sid         = "PublicReadGetObject"
    effect      = "Allow"
    actions     = ["s3:GetObject"]
    resources   = ["arn:aws:s3:::${local.website_bucket}/*"]
    principals {
      identifiers = ["*"]
      type = "*"
    }
  }
}

resource "aws_s3_bucket" "site" {

  bucket = local.website_bucket
  acl    = "public-read"
  policy = data.aws_iam_policy_document.website.json

  website {
    index_document = "template.sh"
    error_document = "error.html"
  }

  logging {
    target_bucket = aws_s3_bucket.logs.id
    target_prefix = ""
  }
}

resource "aws_s3_bucket_object" "template" {
  bucket        = local.website_bucket
  key           = "template.sh"
  source        = "../template.sh"
  etag          = filemd5("../template.sh")

  # Ensure that Firefox opens it as page and does not download the file.
  content_type  = "text/plain"
}

resource "aws_route53_zone" "bash_template_com" {
  name = local.domain_name
}

resource "aws_route53_record" "apex" {
  zone_id = aws_route53_zone.bash_template_com.zone_id
  name    = local.domain_name
  type    = "A"
  alias {
    name                    = aws_cloudfront_distribution.bash-template.domain_name
    zone_id                 = aws_cloudfront_distribution.bash-template.hosted_zone_id
    evaluate_target_health  = false
  }
}

resource "aws_acm_certificate" "bash-template-com" {
  provider          = aws.us-east-1
  domain_name       = local.domain_name
  validation_method = "DNS"
  subject_alternative_names = ["*.${local.domain_name}"]

  tags = {
    Name = local.domain_name
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "certificate-validation" {
  # Replacing this resource is flaky. Terraform indicates it may need replacement, then tries to replace
  # it with exactly same record. The old record is not deleted first for some reason. Terraform fails
  # because you cannot create exactly same record as an existing one. To resolve this, import the record
  # into terrafom or delete it manually in AWS console.
  # See https://github.com/terraform-providers/terraform-provider-aws/pull/11335 and
  # https://github.com/terraform-providers/terraform-provider-aws/issues/9024.
  name     = aws_acm_certificate.bash-template-com.domain_validation_options.0.resource_record_name
  type     = aws_acm_certificate.bash-template-com.domain_validation_options.0.resource_record_type
  zone_id  = aws_route53_zone.bash_template_com.zone_id
  records  = [aws_acm_certificate.bash-template-com.domain_validation_options.0.resource_record_value]
  ttl      = 60
}

resource "aws_acm_certificate_validation" "bash-template-com" {
  # Takes 5 minutes to validate.
  provider                = aws.us-east-1
  certificate_arn         = aws_acm_certificate.bash-template-com.arn
  validation_record_fqdns = [aws_route53_record.certificate-validation.fqdn]
}


resource "aws_cloudfront_distribution" "bash-template" {
  // origin is where CloudFront gets its content from.
  origin {
    // We need to set up a "custom" origin because otherwise CloudFront won't
    // redirect traffic from the root domain to the www domain, that is from
    // runatlantis.io to www.runatlantis.io.
    custom_origin_config {
      // These are all the defaults.
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }

    domain_name = aws_s3_bucket.site.website_endpoint
    origin_id   = aws_s3_bucket.site.bucket_domain_name
  }

  enabled             = true
  default_root_object = "template.sh"

  // All values are defaults from the AWS console.
  default_cache_behavior {
    viewer_protocol_policy = "allow-all"
    compress               = true
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    // This needs to match the `origin_id` above.
    target_origin_id       = aws_s3_bucket.site.bucket_domain_name
    min_ttl                = 0
    default_ttl            = 60
    max_ttl                = 31536000

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  aliases = ["www.${local.domain_name}", local.domain_name]

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.bash-template-com.arn
    ssl_support_method  = "sni-only"
  }

  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.logs.bucket_domain_name
    prefix          = "cloudfront"
  }

  depends_on = [aws_acm_certificate_validation.bash-template-com]
}
