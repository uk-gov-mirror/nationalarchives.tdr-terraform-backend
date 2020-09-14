output "terraform_state_bucket_arn" {
  value = aws_s3_bucket.tdr_terraform_state.arn
}

output "terraform_jenkins_state_bucket" {
  value = aws_s3_bucket.tdr_terraform_state_jenkins.arn
}

output "terraform_grafana_state_bucket_arn" {
  value = aws_s3_bucket.tdr_terraform_state_grafana.arn
}