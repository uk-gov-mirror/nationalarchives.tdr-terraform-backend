output "read_terraform_state_policy_arn" {
  value = aws_iam_policy.read_terraform_state.arn
}

output "terraform_state_lock_access_arn" {
  value = aws_iam_policy.terraform_state_lock_access.arn
}

output "terraform_describe_account_arn" {
  value = aws_iam_policy.terraform_describe_account.arn
}

output "custodian_get_parameters_arn" {
  value = aws_iam_policy.custodian_get_parameters.arn
}
