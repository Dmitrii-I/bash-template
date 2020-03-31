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
  website_bucket      = "bash-template-site"
  website_logs_bucket = "bash-template-site-logs"
}

provider "aws" {
  region              = local.aws_default_region
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
  bucket  = local.website_bucket
  key     = "template.sh"
  source  = "../template.sh"
  etag    = filemd5("../template.sh")
}

resource "aws_route53_zone" "bash_template_com" {
  name = local.domain_name
}

resource "aws_route53_record" "apex" {
  zone_id = aws_route53_zone.bash_template_com.zone_id
  name    = local.domain_name
  type    = "A"
  alias {
    name                    = aws_s3_bucket.site.website_endpoint
    zone_id                 = aws_s3_bucket.site.hosted_zone_id
    evaluate_target_health  = false
  }
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.bash_template_com.zone_id
  name    = "www.${local.domain_name}"
  type    = "A"
  alias {
    name                    = aws_s3_bucket.site.website_endpoint
    zone_id                 = aws_s3_bucket.site.hosted_zone_id
    evaluate_target_health  = false
  }
}
