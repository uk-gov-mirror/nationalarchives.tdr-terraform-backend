output "terraform_state_lock_arn" {
  value = aws_dynamodb_table.terraform_state_lock.arn
}

output "terraform_jenkins_state_lock" {
  value = aws_dynamodb_table.terraform_state_lock_jenkins.arn
}