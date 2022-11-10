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

data "aws_ssm_parameter" "slack_webhook_url" {
  name = "/mgmt/release/slack/webhook"
}

data "aws_ssm_parameter" "slack_notifications_webhook_url" {
  name = "/mgmt/slack/notifications/webhook"
}

data "aws_ssm_parameter" "slack_pr_monitor_url" {
  name = "/mgmt/pr_monitor/slack/webhook"
}

data "aws_ssm_parameter" "npm_token" {
  name = "/mgmt/npm_token"
}

data "aws_ssm_parameter" "gpg_passphrase" {
  name = "/mgmt/github/gpg/passphrase"
}

data "aws_ssm_parameter" "slack_bot_token" {
  name = "/mgmt/slack/bot"
}

data "aws_ssm_parameter" "gpg_key" {
  name = "/mgmt/github/gpg/key"
}

data "aws_ssm_parameter" "gpg_key_id" {
  name = "/mgmt/github/gpg/id"
}

data "aws_ssm_parameter" "sonatype_username" {
  name = "/mgmt/sonatype/username"
}

data "aws_ssm_parameter" "sonatype_password" {
  name = "/mgmt/sonatype/password"
}

data "aws_s3_bucket" "state_bucket" {
  bucket = local.backend_state_bucket
}

data "aws_dynamodb_table" "state_lock_table" {
  name = local.backend_state_lock
}
