variable "tdr_environment" {
  description = "The TDR environment"
  type        = string
}

variable "sub_domain" {}

variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
}

variable "tdr_mgmt_account_number" {
  description = "AWS management account number"
  type        = string
}

variable "terraform_external_id" {
  description = "The external ID to use when assuming the role for terraform-environments"
}

variable "terraform_scripts_external_id" {
  description = "The external ID to use when assuming the role for terraform-scripts"
}

variable "restore_db_external_id" {
  description = "The external ID to use when assuming the role for terraform running the restore database script"
}

variable "grafana_management_external_id" {
  description = "The external ID to use when assuming the role for Grafana to load data from the accounts"
}
