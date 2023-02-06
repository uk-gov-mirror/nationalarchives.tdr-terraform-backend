variable "common_tags" {
  description = "Set of tags that are common for all resources"
  type        = map(string)
}

variable "terraform_state_bucket" {
  description = "S3 bucket storing the terraform state for the different TDR AWS environments"
  type        = string
}

variable "terraform_scripts_state_bucket" {
  description = "S3 bucket storing the terraform state for TDR scripts terraform"
  type        = string
}

variable "terraform_state_lock" {
  description = "DynamoDb table controlling the terraform state lock"
  type        = string
}

variable "terraform_scripts_state_lock" {
  description = "DynamoDb table controlling the TDR scripts terraform state lock"
  type        = string
}

variable "terraform_backend_state_bucket" {
  description = "S3 bucket used for the backend state"
}

variable "terraform_backend_state_lock" {
  description = "DynamoDb table controlling the backend terraform state lock"
}

variable "management_account_number" {}

variable "environment" {}
