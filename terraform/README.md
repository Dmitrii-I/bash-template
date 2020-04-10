# Terraform configuration

This directory contains Terraform configuration.

To run terraform, use this template:

```
TF_CLI_CONFIG_FILE=~/.terraformrc-bash-template terraform plan -var="budget_alerts_email=me@example.com" -var="aws_profile=bash-template"
```

The file `~/.terraformrc-bash-template` should contain credentials block with the Terraform user token.
