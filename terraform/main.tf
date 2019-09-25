terraform {
  backend "local" {
    path = "~/bash-template/terraform/terraform.tfstate"
  }
}

provider "aws" {
  region    = var.aws_region
  profile   = "dmitrii-bash-template.com"
}

resource "aws_s3_bucket" "b" {
  bucket = "bash-template.com-${terraform.workspace}"
  acl    = "public-read"

  website {
    index_document = "index.html"
    error_document = "error.html"

  }
}
