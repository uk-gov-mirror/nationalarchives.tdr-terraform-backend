variable "common_tags" {
  description = "Set of tags that are common for all resources"
  type        = map(string)
}

variable "terraform_state_bucket_kms_key_arn" {
  description = "Customer managed encryption key for Terraform state buckets"
}
