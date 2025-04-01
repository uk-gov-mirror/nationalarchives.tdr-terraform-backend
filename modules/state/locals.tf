locals {
  common_tags = merge(var.common_tags, var.aws_backup_tag)
  state_buckets = [
    aws_s3_bucket.tdr_terraform_state,
    aws_s3_bucket.tdr_terraform_state_github,
    aws_s3_bucket.tdr_terraform_state_grafana,
    aws_s3_bucket.tdr_terraform_state_scripts
  ]
}
