//IAM Group: Deny All Access

resource "aws_iam_group" "tdr_deny_access" {
  name = "TDRDenyAccess"
}

resource "aws_iam_group_policy_attachment" "deny_all_access" {
  group      = aws_iam_group.tdr_deny_access.name
  policy_arn = "arn:aws:iam::aws:policy/AWSDenyAll"
}

//TDR Environment Account Numbers

data "aws_ssm_parameter" "intg_account_number" {
  name = "/mgmt/intg_account"
}

data "aws_ssm_parameter" "staging_account_number" {
  name = "/mgmt/staging_account"
}

data "aws_ssm_parameter" "prod_account_number" {
  name = "/mgmt/prod_account"
}

module "intg_specific_permissions" {
  source                          = "./specific-environment"
  common_tags                     = var.common_tags
  terraform_state_bucket          = var.terraform_state_bucket
  terraform_state_lock            = var.terraform_state_lock
  tdr_account_number              = data.aws_ssm_parameter.intg_account_number.value
  tdr_environment                 = "intg"
  read_terraform_state_policy_arn = aws_iam_policy.read_terraform_state.arn
  terraform_state_lock_access_arn = aws_iam_policy.terraform_state_lock_access.arn
  terraform_describe_account_arn  = aws_iam_policy.terraform_describe_account.arn
}

module "staging_specific_permissions" {
  source                          = "./specific-environment"
  common_tags                     = var.common_tags
  terraform_state_bucket          = var.terraform_state_bucket
  terraform_state_lock            = var.terraform_state_lock
  tdr_account_number              = data.aws_ssm_parameter.staging_account_number.value
  tdr_environment                 = "staging"
  read_terraform_state_policy_arn = aws_iam_policy.read_terraform_state.arn
  terraform_state_lock_access_arn = aws_iam_policy.terraform_state_lock_access.arn
  terraform_describe_account_arn  = aws_iam_policy.terraform_describe_account.arn
}

module "prod_specific_permissions" {
  source                          = "./specific-environment"
  common_tags                     = var.common_tags
  terraform_state_bucket          = var.terraform_state_bucket
  terraform_state_lock            = var.terraform_state_lock
  tdr_account_number              = data.aws_ssm_parameter.prod_account_number.value
  tdr_environment                 = "prod"
  read_terraform_state_policy_arn = aws_iam_policy.read_terraform_state.arn
  terraform_state_lock_access_arn = aws_iam_policy.terraform_state_lock_access.arn
  terraform_describe_account_arn  = aws_iam_policy.terraform_describe_account.arn
}
