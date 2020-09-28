variable "app_name" {
  default = "grafana"
}

variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
}

variable "sub_domain" {
  default = "tdr-management"
}

variable "tdr_environment" {
  description = "The TDR environment"
  type        = string
}

variable "tdr_mgmt_account_number" {
  description = "AWS management account number"
  type        = string
}

variable "terraform_grafana_state_bucket" {}

variable "terraform_grafana_state_lock" {}