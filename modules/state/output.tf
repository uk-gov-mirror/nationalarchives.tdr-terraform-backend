output "terraform_state_bucket_arn" {
  value = aws_s3_bucket.tdr_terraform_state.arn
}