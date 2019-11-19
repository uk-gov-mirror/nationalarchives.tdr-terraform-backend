# TDR Terraform Management

Terraform code that creates the necessary "backend" to support Terraforming the TDR application.

Specific resources created:
* S3 Bucket: contains the Terraform state files for each TDR workspace
* DyanmoDB table: used for locking to prevent concurrent operations on a single workspace

These resources are used by the TDR application Terraform code.

## TDR AWS Accounts

Three TDR Application AWS accounts are used to host the different environments:
* CI
* Test
* Prod

In addition there is a TDR Management AWS account which is used to host the Terraform backend.

### IAM Role Delegation

IAM role delegation will be used to allow users in the AWS management account to have access to the TDR environment AWS accounts to perform terraforming operations.

IAM policies are defined to create a trust relationship between the TDR environment AWS accounts (trusting account) and the management AWS account (trusted account).

Example of the IAM policy that needs to be added to the user group(s) in the AWS management account:
 
```
    {
      "Version": "2012-10-17",
      "Statement": {
        "Effect": "Allow",
        "Action": "sts:AssumeRole",
        "Resource": "arn:aws:iam::TDR-ENVIORNMENT-ID:role/Terraform"
      }
    }
```

Reciprocal policies need to be defined for IAM roles in the TDR environment accounts to allow users from the management AWS account to have access to the necessary resources to perform the terraforming of the TDR environments.

## IAM User Groups

Two user groups are defined: "developer"; "administrator". This is to limit which users will have permission to apply Terraform changes to the "test" and "prod" TDR environments.

## Further Information

* Setting up multi-account AWS architecture with Terraform: https://www.terraform.io/docs/backends/types/s3.html#multi-account-aws-architecture
* Providing Access to an IAM User in Another AWS Account That You Own: https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_common-scenarios_aws-accounts.html
* Tutorial - Delegate Access Across AWS Accounts Using IAM Roles: https://docs.aws.amazon.com/IAM/latest/UserGuide/tutorial_cross-account-with-roles.html