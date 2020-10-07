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

variable "release_bucket_arn" {
  description = "The bucket arn for release artefacts"
  type        = string
}

variable "staging_bucket_arn" {
  description = "The bucket arn for staging artefacts"
  type        = string
}

variable "management_account_number" {}