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

data "aws_ssm_parameter" "npm_token" {
  name = "/mgmt/npm_token"
}

data "aws_ssm_parameter" "gpg_passphrase" {
  name = "	/mgmt/github/gpg/passphrase"
}

data "aws_ssm_parameter" "gpg_key" {
  name = "	/mgmt/github/gpg/key"
}

data "aws_ssm_parameter" "sonatype_username" {
  name = "	/mgmt/sonatype/username"
}

data "aws_ssm_parameter" "sonatype_password" {
  name = "	/mgmt/sonatype/password"
}
