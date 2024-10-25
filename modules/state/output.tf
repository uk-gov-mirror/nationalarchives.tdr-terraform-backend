output "terraform_state_bucket_arn" {
  value = aws_s3_bucket.tdr_terraform_state.arn
}

output "terraform_grafana_state_bucket_arn" {
  value = aws_s3_bucket.tdr_terraform_state_grafana.arn
}

output "terraform_scripts_state_bucket_arn" {
  value = aws_s3_bucket.tdr_terraform_state_scripts.arn
}

output "terraform_github_state_bucket_arn" {
  value = aws_s3_bucket.tdr_terraform_state_github.arn
}
