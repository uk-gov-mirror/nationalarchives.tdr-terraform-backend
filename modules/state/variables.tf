variable "common_tags" {
  description = "Set of tags that are common for all resources"
  type        = map(string)
}

variable "terraform_state_bucket_kms_key_arn" {
  description = "Customer managed encryption key for Terraform state buckets"
}

variable "aws_backup_local_role_arn" {
  description = "IAM role used for centralised backups"
}

variable "aws_backup_tag" {
  description = "Tag to identify resource for backing up"
  default     = null
}
