output "terraform_state_lock_arn" {
  value = aws_dynamodb_table.terraform_state_lock.arn
}

output "terraform_grafana_state_lock_arn" {
  value = aws_dynamodb_table.terraform_state_lock_grafana.arn
}

output "terraform_scripts_state_lock_arn" {
  value = aws_dynamodb_table.terraform_state_lock_scripts.arn
}

output "terraform_github_state_lock_arn" {
  value = aws_dynamodb_table.terraform_github_state_lock.arn
}

