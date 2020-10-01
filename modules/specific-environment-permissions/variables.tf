variable "common_tags" {
  description = "Set of tags that are common for all resources"
  type        = map(string)
}

variable "terraform_state_bucket" {
  description = "S3 bucket storing the terraform state for the different TDR AWS environments"
  type        = string
}

variable "terraform_state_lock" {
  description = "DynamoDb table controlling the terraform state lock"
  type        = string
}

variable "tdr_account_number" {
  description = "AWS account number where TDR environment is hosted"
  type        = string
}

variable "tdr_environment" {
  description = "TDR environment"
  type        = string
}

variable "read_terraform_state_policy_arn" {
  description = "IAM policy ARN for reading Terraform state"
  type        = string
}

variable "terraform_state_lock_access_arn" {
  description = "IAM policy ARN for accessing Terraform state lock"
  type        = string
}

variable "terraform_describe_account_arn" {
  description = "IAM policy ARN for describing account"
  type        = string
}

variable "custodian_get_parameters_arn" {
  description = "IAM policy ARN for getting parameter values"
  type        = string
}

variable "terraform_scripts_state_bucket" {
  description = "S3 bucket storing the terraform state for the TDR scripts terraform project"
  type        = string
}