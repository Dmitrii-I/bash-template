# Terraform configuration

This directory contains Terraform configuration.

Terraform state is stored locally but is not in git. We store in git the zipped and encrypted Terraform state. The command we use: `zip terraform.tfstate.d.zip terraform.tfstate.d --encrypt`. Because of this, we must not forget to save the state in git everytime it changes.

We tried to use S3 backend but it is not possible to do it the way we want because Terraform does not allow variables in `terraform` block, which leads to repetitive hard-coded values in multiple modules.

