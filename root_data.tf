data "aws_ssm_parameter" "intg_account_number" {
  name = "/mgmt/intg_account"
}

data "aws_ssm_parameter" "staging_account_number" {
  name = "/mgmt/staging_account"
}

data "aws_ssm_parameter" "prod_account_number" {
  name = "/mgmt/prod_account"
}

data "aws_ssm_parameter" "mgmt_account_number" {
  name = "/mgmt/management_account"
}

data "aws_ssm_parameter" "sandbox_account_number" {
  name = "/mgmt/sandbox_account"
}

data "aws_ssm_parameter" "cost_centre" {
  name = "/mgmt/cost_centre"
}

data "aws_ssm_parameter" "workflow_pat" {
  name = "/mgmt/workflow_pat"
}

data "aws_ssm_parameter" "slack_webhook_url" {
  name = "/mgmt/release/slack/webhook"
}
