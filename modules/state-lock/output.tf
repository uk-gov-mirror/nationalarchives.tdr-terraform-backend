output "terraform_state_lock_arn" {
  value = aws_dynamodb_table.terraform_state_lock.arn
}