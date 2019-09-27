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

resource "aws_s3_bucket" "site" {

  bucket = local.site_names[terraform.workspace]
  acl    = "public-read"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  logging {
    target_bucket = aws_s3_bucket.logs.id
    target_prefix = ""
  }

}

