# TDR Terraform Management

Terraform code that creates the necessary "backend" to support Terraforming the TDR application

Specific resources created:
* S3 Bucket: contains the Terraform state files for each TDR workspace
* DyanmoDB table: used for locking to prevent concurrent operations on a single workspace

These resources are used by the TDR application Terraform code.

## Further Information

* Setting up multi-account AWS architecture with Terraform: https://www.terraform.io/docs/backends/types/s3.html#multi-account-aws-architecture
