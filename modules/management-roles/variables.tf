variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
}

variable "sub_domain" {}

variable "tdr_environment" {
  description = "The TDR environment"
  type        = string
}

variable "tdr_mgmt_account_number" {
  description = "AWS management account number"
  type        = string
}