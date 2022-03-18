output "terraform_ecs_policy_arn" {
  value = aws_iam_policy.terraform_ecs_policy.arn
}

output "access_terraform_state_arn" {
  value = aws_iam_policy.access_terraform_state.arn
}
