# TDR Terraform Backend

## Purpose

The purpose of this repository is to setup the necessary Terraform backend AWS resources to support terraforming for the TDR application AWS resources.

The Terraform scripts are to be used as a one off operation, and not to retain the state.

Specific resources created:
* AWS TDR Management account resources:
  * **S3 Bucket**: contains the Terraform state files for each TDR workspace
  * **DyanmoDB table**: used for locking to prevent concurrent operations on a single workspace
* AWS TDR Environment accounts resources:
  * **Terraform IAM Roles**: IAM role to allow creation of AWS resource within the environment using Terraform (Terraform IAM role)
  * **IAM Policies**: Specific IAM policies to give permissions to the Terraform IAM role

These resources are used by the TDR application Terraform code: https://github.com/nationalarchives/tdr-terraform-environments

The Terraform IAM roles are assumed by the TDR AWS Management account user running the TDR application Terraform code.

## Getting Started

### Install Terraform locally

See: https://learn.hashicorp.com/terraform/getting-started/install.html

## Running the Project

1. Clone the project to local machine: https://github.com/nationalarchives/tdr-terraform-backend

2. Add AWS credentials to the local credential store (~/.aws/credentials):

   ```
   ... other credentials ...
   [management]
   aws_access_key_id = ... management user access key ...
   aws_secret_access_key = ... management user secret key ...
   ```

  * These credentials will be used to create the Terraform backend and set up the individual Terraform environments with IAM roles that will allow Terraform to create the AWS resources in that TDR environment.
  * See instructions here: https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html

3. Add AWS profiles to the local config store (~/.aws/config):

   ```
   [profile intgaccess]
   region = eu-west-2
   role_arn = ... arn of the IAM role that provides admin access to the TDR intg AWS account ...
   source_profile = management
   
   [profile prodaccess]
   region = eu-west-2
   role_arn = ... arn of the IAM role that provides admin access to the TDR staging/prod AWS account ...
   source_profile = management
   ```
  * The profiles allow Terraform to assume IAM roles in the TDR environment accounts to create IAM roles and policies which give permissions for the creation of AWS resources by Terraform.
  
4. Open command terminal on local machine and navigate to the environment-roles module: ./modules/environment-roles

5. Create Terraform workspaces in the environment-roles module for each of the TDR environments:

   ```
   [environment-roles] $ terraform workspace new intg
   
   [environment-roles] $ terraform workspace new staging
   
   [environment-roles] $ terraform workspapce new prod
   ```

6. Run the following command to ensure Terraform uses the correct credentials:

   ```
   [environment-roles] $ export AWS_PROFILE=management
   ```
   
7. Select each Terraform workspace and create the Terraform IAM roles for each of the TDR environments in their corresponding AWS accounts:

   ```
   [environment-roles] $ terraform workspace select intg
   
   [environment-roles] $ terrform apply
   ```
   
   * This will create the IAM roles that will be assumed by the TDR AWS management account to give permission for Terraform to create the AWS resources for the TDR environment.

8. Navigate back to the root of the project from the environment-roles module and run the Terraform root in the ***default*** Terraform workspace:

   ```
   [location of project] $ terraform workspace select default   
   
   [location of project] $ terraform apply
   ```

  * This will generate the Terraform backend (s3 bucket and DynamoDb) which will store the Terraform state for the TDR environments in each of the TDR AWS environment accounts.

Once the Terraform Backend project has been setup the following AWS backend resources should be available in the AWS TDR Management account:

  * S3 Buckets: 
    * tdr-terraform-state; 
    * tdr-terraform-state-jenkins
  * DyanmoDb Tables: 
    * tdr-terraform-state-lock; 
    * tdr-state-lock-jenkins
  * IAM Groups: 
    * tdr-terraform-administrators; 
    * tdr-terraform-developers
  * IAM Policies: 
    * *[env name]*_access_terraform_state; 
    * *[env name]*_terraform_assume_role_policy; 
    * read_terraform_state; 
    * terraform_state_lock_access
  
In the TDR AWS environment accounts the following AWS resources should be available in each of the AWS accounts:
  * IAM Role: *[env name]*-terraform-role
  * IAM Policies:
    * s3-terraform-policy-*[env name]*
    * *[further policies to be added as needed]*   

## Background to TDR AWS Structure

### TDR AWS Accounts

Three TDR Application AWS accounts are used to host the different environments:
* Integration (intg)
* Staging (staging)
* Production (prod)

In addition there is a TDR Management AWS account which is used to host the Terraform backend and Jenkins.

### IAM Role Delegation

IAM role delegation is used to allow users in the AWS management account to have access to the TDR environment AWS accounts to perform terraforming operations.

IAM policies are defined to create a trust relationship between the TDR environment AWS accounts (trusting account) and the management AWS account (trusted account).

Example of the IAM policy that needs to be added to the user group(s) in the AWS management account:
 
```
    {
      "Version": "2012-10-17",
      "Statement": {
        "Effect": "Allow",
        "Action": "sts:AssumeRole",
        "Resource": "arn:aws:iam::TDR-ENVIORNMENT-ID:role/[environment name]-terraform-role"
      }
    }
```

Reciprocal policies need to be defined for IAM roles in the TDR environment accounts to allow users from the management AWS account to have access to the necessary resources to perform the terraforming of the TDR environments.

The TDR Terraform script can the access the Terraform backend in the following way:

```
...
variable "workspace_iam_roles" {
  default = {
    intg    = "arn:aws:iam::INTG-ACCOUNT-ID:role/intg-terraform-role"
    staging = "arn:aws:iam::STAGING-ACCOUNT-ID:role/staging-terraform-role"
    prod    = "arn:aws:iam::PRODUCTION-ACCOUNT-ID:role/prod-terraform-role"
  }
}

terraform {
  backend "s3" {
    bucket = "[name of the bucket created in the backend Terraform]"
    key = "prototype-terraform.state"
    region = "eu-west-2"
    encrypt = true
    dynamodb_table = "[name of the DynamoDb created in the backend Terraform]"
  }
}

provider "aws" {
  region      = local.aws_region
  assume_role = var.workspace_iam_roles[terraform.workspace]
}
...

```

### IAM User Groups

Two user groups are defined: "developer"; "administrator". This is to limit which users will have permission to apply Terraform changes to the "staging" and "production" TDR environments.

## Further Information

* Setting up multi-account AWS architecture with Terraform: https://www.terraform.io/docs/backends/types/s3.html#multi-account-aws-architecture
* Providing Access to an IAM User in Another AWS Account That You Own: https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_common-scenarios_aws-accounts.html
* Tutorial - Delegate Access Across AWS Accounts Using IAM Roles: https://docs.aws.amazon.com/IAM/latest/UserGuide/tutorial_cross-account-with-roles.html