variable "common_tags" {
  description = "Set of tags that are common for all resources"
  type        = map(string)
}

variable "terraform_state_bucket" {
  description = "S3 bucket storing the terraform state for the different TDR AWS environments"
  type        = string
}