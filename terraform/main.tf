locals {
  site_names = {
    "prod": "bash-template.com",
    "dev": "bash-template.com-dev"
  }
}

terraform {
  backend "local" {
    path = "~/bash-template/terraform/terraform.tfstate"
  }
}

provider "aws" {
  region    = var.aws_region
  profile   = "dmitrii-bash-template.com"
}

resource "aws_s3_bucket" "logs" {
  bucket = "${local.site_names[terraform.workspace]}-site-logs"
  acl = "log-delivery-write"
}

data "aws_iam_policy_document" "website" {
  statement {
    sid         = "PublicReadGetObject"
    effect      = "Allow"
    actions     = ["s3:GetObject"]
    resources   = ["arn:aws:s3:::${local.site_names[terraform.workspace]}/*"]
    principals {
      identifiers = ["*"]
      type = "*"
    }
  }
}

resource "aws_s3_bucket" "site" {

  bucket = local.site_names[terraform.workspace]
  acl    = "public-read"
  policy = data.aws_iam_policy_document.website.json

  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  logging {
    target_bucket = aws_s3_bucket.logs.id
    target_prefix = ""
  }

}

