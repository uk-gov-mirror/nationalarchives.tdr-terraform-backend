module "run_e2e_tests_role" {
  source             = "./tdr-terraform-modules/iam_role"
  assume_role_policy = templatefile("${path.module}/templates/iam_role/github_assume_role.json.tpl", { account_id = data.aws_ssm_parameter.mgmt_account_number.value, repo_name = "tdr-e2e-tests:*" })
  common_tags        = local.common_tags
  name               = "TDRGithubActionsE2ETestsMgmt"
  policy_attachments = {
    export_intg    = "arn:aws:iam::${data.aws_ssm_parameter.mgmt_account_number.value}:policy/TDRJenkinsNodeS3ExportPolicyIntg"
    export_staging = "arn:aws:iam::${data.aws_ssm_parameter.mgmt_account_number.value}:policy/TDRJenkinsNodeS3ExportPolicyStaging"
  }
}

module "github_sbt_dependencies_policy" {
  source        = "./tdr-terraform-modules/iam_policy"
  name          = "TDRGithubDependenciesPolicyMgmt"
  policy_string = templatefile("${path.module}/templates/iam_policy/github_sbt_dependencies_policy.json.tpl", {})
}

module "github_ecr_policy" {
  source        = "./tdr-terraform-modules/iam_policy"
  name          = "TDRGithubECRPolicyMgmt"
  policy_string = templatefile("${path.module}/templates/iam_policy/github_ecr_policy.json.tpl", { account_id = data.aws_ssm_parameter.mgmt_account_number.value })
}

module "github_ecr_policy_sbox" {
  source        = "./tdr-terraform-modules/iam_policy"
  name          = "TDRGithubECRPolicySbox"
  policy_string = templatefile("${path.module}/templates/iam_policy/github_ecr_policy.json.tpl", { account_id = data.aws_ssm_parameter.sandbox_account_number.value })
}

module "github_actions_code_bucket_policy" {
  source        = "./tdr-terraform-modules/iam_policy"
  name          = "TDRGithubActionsBackendCodeMgmt"
  policy_string = templatefile("${path.module}/templates/iam_policy/github_code_bucket.json.tpl", {})
}

module "github_actions_role" {
  source             = "./tdr-terraform-modules/iam_role"
  assume_role_policy = templatefile("${path.module}/templates/iam_role/github_assume_role.json.tpl", { account_id = data.aws_ssm_parameter.mgmt_account_number.value, repo_name = "tdr-*" })
  common_tags        = local.common_tags
  name               = "TDRGithubActionsRoleMgmt"
  policy_attachments = {
    dependencies = module.github_sbt_dependencies_policy.policy_arn,
    ecr          = module.github_ecr_policy.policy_arn
    backend_code = module.github_actions_code_bucket_policy.policy_arn
  }
}

module "github_oidc_provider" {
  source      = "./tdr-terraform-modules/identity_provider"
  audience    = "sts.amazonaws.com"
  thumbprint  = "6938fd4d98bab03faadb97b34396831e3780aea1"
  url         = "https://token.actions.githubusercontent.com"
  common_tags = local.common_tags
}

module "github_transfer_frontend_repository" {
  source          = "./tdr-terraform-modules/github_repositories"
  repository_name = "nationalarchives/tdr-transfer-frontend"
  secrets = {
    MANAGEMENT_ACCOUNT = data.aws_ssm_parameter.mgmt_account_number.value
    WORKFLOW_PAT       = module.common_ssm_parameters.params[local.github_access_token_name].value
    SLACK_WEBHOOK      = data.aws_ssm_parameter.slack_webhook_url.value
  }
}

module "github_consignment_api_repository" {
  source          = "./tdr-terraform-modules/github_repositories"
  repository_name = "nationalarchives/tdr-consignment-api"
  secrets = {
    MANAGEMENT_ACCOUNT = data.aws_ssm_parameter.mgmt_account_number.value
    WORKFLOW_PAT       = module.common_ssm_parameters.params[local.github_access_token_name].value
    SLACK_WEBHOOK      = data.aws_ssm_parameter.slack_webhook_url.value
  }
}

module "github_e2e_tests_repository" {
  source          = "./tdr-terraform-modules/github_repositories"
  repository_name = "nationalarchives/tdr-e2e-tests"
  secrets = {
    MANAGEMENT_ACCOUNT = data.aws_ssm_parameter.mgmt_account_number.value
    SLACK_WEBHOOK      = data.aws_ssm_parameter.slack_webhook_url.value
  }
}

module "github_checksum_repository" {
  source          = "./tdr-terraform-modules/github_repositories"
  repository_name = "nationalarchives/tdr-checksum"
  secrets = {
    MANAGEMENT_ACCOUNT = data.aws_ssm_parameter.mgmt_account_number.value
    SLACK_WEBHOOK      = data.aws_ssm_parameter.slack_webhook_url.value
    WORKFLOW_PAT       = module.common_ssm_parameters.params[local.github_access_token_name].value
  }
}

module "github_terraform_environments_repository" {
  source          = "./tdr-terraform-modules/github_repositories"
  repository_name = "nationalarchives/tdr-terraform-environments"
  secrets = {
    MANAGEMENT_ACCOUNT = data.aws_ssm_parameter.mgmt_account_number.value
    SLACK_WEBHOOK      = data.aws_ssm_parameter.slack_webhook_url.value
    WORKFLOW_PAT       = module.common_ssm_parameters.params[local.github_access_token_name].value
  }
}

module "github_terraform_modules_repository" {
  source          = "./tdr-terraform-modules/github_repositories"
  repository_name = "nationalarchives/tdr-terraform-modules"
  secrets = {
    MANAGEMENT_ACCOUNT = data.aws_ssm_parameter.mgmt_account_number.value
    SLACK_WEBHOOK      = data.aws_ssm_parameter.slack_webhook_url.value
    WORKFLOW_PAT       = module.common_ssm_parameters.params[local.github_access_token_name].value
  }
}

module "github_terraform_backend_repository" {
  source          = "./tdr-terraform-modules/github_repositories"
  repository_name = "nationalarchives/tdr-terraform-backend"
  secrets = {
    MANAGEMENT_ACCOUNT = data.aws_ssm_parameter.mgmt_account_number.value
    WORKFLOW_PAT       = module.common_ssm_parameters.params[local.github_access_token_name].value
  }
}

module "github_cloudwatch_terraform_plan_outputs_intg" {
  source      = "./tdr-terraform-modules/cloudwatch_logs"
  common_tags = local.common_tags
  name        = "terraform-plan-outputs-intg"
}

module "github_cloudwatch_terraform_plan_outputs_staging" {
  source      = "./tdr-terraform-modules/cloudwatch_logs"
  common_tags = local.common_tags
  name        = "terraform-plan-outputs-staging"
}

module "github_cloudwatch_terraform_plan_outputs_prod" {
  source      = "./tdr-terraform-modules/cloudwatch_logs"
  common_tags = local.common_tags
  name        = "terraform-plan-outputs-prod"
}

module "github_cloudwatch_terraform_plan_outputs_mgmt" {
  source      = "./tdr-terraform-modules/cloudwatch_logs"
  common_tags = local.common_tags
  name        = "terraform-plan-outputs-mgmt"
}

module "github_cloudwatch_terraform_plan_policy" {
  source        = "./tdr-terraform-modules/iam_policy"
  name          = "TDRGithubCloudwatchTerraformPlanPolicy"
  policy_string = templatefile("${path.module}/templates/iam_policy/github_cloudwatch_policy.json.tpl", { account_id = data.aws_ssm_parameter.mgmt_account_number.value })
}

module "github_terraform_assume_role_intg" {
  source             = "./tdr-terraform-modules/iam_role"
  assume_role_policy = templatefile("${path.module}/templates/iam_role/github_assume_role.json.tpl", { account_id = data.aws_ssm_parameter.mgmt_account_number.value, repo_name = "tdr-*" })
  common_tags        = local.common_tags
  name               = "TDRGithubTerraformAssumeRoleIntg"
  policy_attachments = {
    terraform_ecs_policy_arn        = module.intg_specific_permissions.terraform_ecs_policy_arn
    access_terraform_state_arn      = module.intg_specific_permissions.access_terraform_state_arn
    read_terraform_state_policy_arn = module.common_permissions.read_terraform_state_policy_arn
    terraform_state_lock_access_arn = module.common_permissions.terraform_state_lock_access_arn
    terraform_describe_account_arn  = module.common_permissions.terraform_describe_account_arn
    cloudfront_policy               = module.github_cloudwatch_terraform_plan_policy.policy_arn
  }
}

module "github_terraform_assume_role_staging" {
  source             = "./tdr-terraform-modules/iam_role"
  assume_role_policy = templatefile("${path.module}/templates/iam_role/github_assume_role.json.tpl", { account_id = data.aws_ssm_parameter.mgmt_account_number.value, repo_name = "tdr-*" })
  common_tags        = local.common_tags
  name               = "TDRGithubTerraformAssumeRoleStaging"
  policy_attachments = {
    terraform_ecs_policy_arn        = module.staging_specific_permissions.terraform_ecs_policy_arn
    access_terraform_state_arn      = module.staging_specific_permissions.access_terraform_state_arn
    read_terraform_state_policy_arn = module.common_permissions.read_terraform_state_policy_arn
    terraform_state_lock_access_arn = module.common_permissions.terraform_state_lock_access_arn
    terraform_describe_account_arn  = module.common_permissions.terraform_describe_account_arn
    cloudfront_policy               = module.github_cloudwatch_terraform_plan_policy.policy_arn
  }
}

module "github_terraform_assume_role_prod" {
  source             = "./tdr-terraform-modules/iam_role"
  assume_role_policy = templatefile("${path.module}/templates/iam_role/github_assume_role.json.tpl", { account_id = data.aws_ssm_parameter.mgmt_account_number.value, repo_name = "tdr-*" })
  common_tags        = local.common_tags
  name               = "TDRGithubTerraformAssumeRoleProd"
  policy_attachments = {
    terraform_ecs_policy_arn        = module.prod_specific_permissions.terraform_ecs_policy_arn
    access_terraform_state_arn      = module.prod_specific_permissions.access_terraform_state_arn
    read_terraform_state_policy_arn = module.common_permissions.read_terraform_state_policy_arn
    terraform_state_lock_access_arn = module.common_permissions.terraform_state_lock_access_arn
    terraform_describe_account_arn  = module.common_permissions.terraform_describe_account_arn
    cloudfront_policy               = module.github_cloudwatch_terraform_plan_policy.policy_arn
  }
}

module "github_terraform_assume_role_sbox" {
  source             = "./tdr-terraform-modules/iam_role"
  assume_role_policy = templatefile("${path.module}/templates/iam_role/github_assume_role.json.tpl", { account_id = data.aws_ssm_parameter.mgmt_account_number.value, repo_name = "tdr-*" })
  common_tags        = local.common_tags
  name               = "TDRGithubTerraformAssumeRoleSbox"
  policy_attachments = {
    terraform_ecs_policy_arn        = module.sbox_specific_permissions.terraform_ecs_policy_arn
    access_terraform_state_arn      = module.sbox_specific_permissions.access_terraform_state_arn
    read_terraform_state_policy_arn = module.common_permissions.read_terraform_state_policy_arn
    terraform_state_lock_access_arn = module.common_permissions.terraform_state_lock_access_arn
    terraform_describe_account_arn  = module.common_permissions.terraform_describe_account_arn
    cloudfront_policy               = module.github_cloudwatch_terraform_plan_policy.policy_arn
    ecr_mgmt_policy                 = module.github_ecr_policy.policy_arn
    ecr_sbox_policy                 = module.github_ecr_policy_sbox.policy_arn
    ssm_policy                      = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
  }
}

module "github_auth_utils_environment" {
  source          = "./tdr-terraform-modules/github_repositories"
  repository_name = "nationalarchives/tdr-auth-utils"
  secrets = {
    WORKFLOW_PAT      = module.common_ssm_parameters.params[local.github_access_token_name].value
    SLACK_WEBHOOK     = data.aws_ssm_parameter.slack_webhook_url.value
    GPG_PASSPHRASE    = data.aws_ssm_parameter.gpg_passphrase.value
    GPG_PRIVATE_KEY   = data.aws_ssm_parameter.gpg_key.value
    SONATYPE_USERNAME = data.aws_ssm_parameter.sonatype_username.value
    SONATYPE_PASSWORD = data.aws_ssm_parameter.sonatype_password.value
  }
}

module "github_actions_repository" {
  source          = "./tdr-terraform-modules/github_repositories"
  repository_name = "nationalarchives/tdr-github-actions"
  secrets = {
    GPG_KEY_ID      = data.aws_ssm_parameter.gpg_key_id.value
    GPG_PASSPHRASE  = data.aws_ssm_parameter.gpg_passphrase.value
    GPG_PRIVATE_KEY = data.aws_ssm_parameter.gpg_key.value
    WORKFLOW_PAT    = module.common_ssm_parameters.params[local.github_access_token_name].value
  }
}

module "github_generated_graphql_environment" {
  source          = "./tdr-terraform-modules/github_repositories"
  repository_name = "nationalarchives/tdr-generated-graphql"
  secrets         = {
    WORKFLOW_PAT      = module.common_ssm_parameters.params[local.github_access_token_name].value
    NPM_TOKEN         = data.aws_ssm_parameter.npm_token.value
    SLACK_WEBHOOK     = data.aws_ssm_parameter.slack_webhook_url.value
    GPG_PASSPHRASE    = data.aws_ssm_parameter.gpg_passphrase.value
    GPG_PRIVATE_KEY   = data.aws_ssm_parameter.gpg_key.value
    SONATYPE_USERNAME = data.aws_ssm_parameter.sonatype_username.value
    SONATYPE_PASSWORD = data.aws_ssm_parameter.sonatype_password.value
  }
  dependabot_secrets = {
    WORKFLOW_PAT = module.common_ssm_parameters.params[local.github_access_token_name].value
  }
}

module "github_graphql_client_environment" {
  source          = "./tdr-terraform-modules/github_repositories"
  repository_name = "nationalarchives/tdr-graphql-client"
  secrets = {
    WORKFLOW_PAT      = module.common_ssm_parameters.params[local.github_access_token_name].value
    SLACK_WEBHOOK     = data.aws_ssm_parameter.slack_webhook_url.value
    GPG_PASSPHRASE    = data.aws_ssm_parameter.gpg_passphrase.value
    GPG_PRIVATE_KEY   = data.aws_ssm_parameter.gpg_key.value
    SONATYPE_USERNAME = data.aws_ssm_parameter.sonatype_username.value
    SONATYPE_PASSWORD = data.aws_ssm_parameter.sonatype_password.value
  }
}

module "github_db_migration_environment" {
  source          = "./tdr-terraform-modules/github_repositories"
  repository_name = "nationalarchives/tdr-consignment-api-data"
  secrets = {
    WORKFLOW_PAT       = module.common_ssm_parameters.params[local.github_access_token_name].value
    SLACK_WEBHOOK      = data.aws_ssm_parameter.slack_webhook_url.value
    GPG_PASSPHRASE     = data.aws_ssm_parameter.gpg_passphrase.value
    GPG_PRIVATE_KEY    = data.aws_ssm_parameter.gpg_key.value
    SONATYPE_USERNAME  = data.aws_ssm_parameter.sonatype_username.value
    SONATYPE_PASSWORD  = data.aws_ssm_parameter.sonatype_password.value
    MANAGEMENT_ACCOUNT = data.aws_ssm_parameter.mgmt_account_number.value
  }
}

module "github_aws_utils_environment" {
  source          = "./tdr-terraform-modules/github_repositories"
  repository_name = "nationalarchives/tdr-aws-utils"
  secrets = {
    WORKFLOW_PAT      = module.common_ssm_parameters.params[local.github_access_token_name].value
    SLACK_WEBHOOK     = data.aws_ssm_parameter.slack_webhook_url.value
    GPG_PASSPHRASE    = data.aws_ssm_parameter.gpg_passphrase.value
    GPG_PRIVATE_KEY   = data.aws_ssm_parameter.gpg_key.value
    SONATYPE_USERNAME = data.aws_ssm_parameter.sonatype_username.value
    SONATYPE_PASSWORD = data.aws_ssm_parameter.sonatype_password.value
  }
}

module "github_auth_server_repository" {
  source          = "./tdr-terraform-modules/github_repositories"
  repository_name = "nationalarchives/tdr-auth-server"
  secrets = {
    MANAGEMENT_ACCOUNT = data.aws_ssm_parameter.mgmt_account_number.value
    WORKFLOW_PAT       = module.common_ssm_parameters.params[local.github_access_token_name].value
    SLACK_WEBHOOK      = data.aws_ssm_parameter.slack_webhook_url.value
  }
}

module "github_consignment_export_repository" {
  source          = "./tdr-terraform-modules/github_repositories"
  repository_name = "nationalarchives/tdr-consignment-export"
  secrets = {
    MANAGEMENT_ACCOUNT = data.aws_ssm_parameter.mgmt_account_number.value
    WORKFLOW_PAT       = module.common_ssm_parameters.params[local.github_access_token_name].value
    SLACK_WEBHOOK      = data.aws_ssm_parameter.slack_webhook_url.value
    GPG_PASSPHRASE     = data.aws_ssm_parameter.gpg_passphrase.value
    GPG_PRIVATE_KEY    = data.aws_ssm_parameter.gpg_key.value
  }
}

module "github_antivirus_repository" {
  source          = "./tdr-terraform-modules/github_repositories"
  repository_name = "nationalarchives/tdr-antivirus"
  secrets = {
    MANAGEMENT_ACCOUNT = data.aws_ssm_parameter.mgmt_account_number.value
    WORKFLOW_PAT       = module.common_ssm_parameters.params[local.github_access_token_name].value
    SLACK_WEBHOOK      = data.aws_ssm_parameter.slack_webhook_url.value
  }
}

module "github_antivirus_rule_checks_policy" {
  source        = "./tdr-terraform-modules/iam_policy"
  name          = "TDRGithubAvRuleChecksPolicyMgmt"
  policy_string = templatefile("${path.module}/templates/iam_policy/github_av_rule_checks.json.tpl", {})
}

module "github_antivirus_rule_checks" {
  source             = "./tdr-terraform-modules/iam_role"
  assume_role_policy = templatefile("${path.module}/templates/iam_role/github_assume_role.json.tpl", { account_id = data.aws_ssm_parameter.mgmt_account_number.value, repo_name = "tdr-antivirus*" })
  common_tags        = local.common_tags
  name               = "TDRGithubAvRuleChecksMgmt"
  policy_attachments = {
    av_rule_check_policy = module.github_antivirus_rule_checks_policy.policy_arn
  }
}

module "github_backend_checks_performance_repository" {
  source          = "./tdr-terraform-modules/github_repositories"
  repository_name = "nationalarchives/tdr-backend-check-performance"
  secrets = {
    MANAGEMENT_ACCOUNT = data.aws_ssm_parameter.mgmt_account_number.value
    SANDBOX_ACCOUNT    = data.aws_ssm_parameter.sandbox_account_number.value
    WORKFLOW_PAT       = module.common_ssm_parameters.params[local.github_access_token_name].value
    SLACK_WEBHOOK      = data.aws_ssm_parameter.slack_webhook_url.value
    GPG_PASSPHRASE     = data.aws_ssm_parameter.gpg_passphrase.value
    GPG_PRIVATE_KEY    = data.aws_ssm_parameter.gpg_key.value
  }
}

module "github_scripts_repository" {
  source          = "./tdr-terraform-modules/github_repositories"
  repository_name = "nationalarchives/tdr-scripts"
  secrets = {
    MANAGEMENT_ACCOUNT = data.aws_ssm_parameter.mgmt_account_number.value
    WORKFLOW_PAT       = module.common_ssm_parameters.params[local.github_access_token_name].value
    SLACK_WEBHOOK      = data.aws_ssm_parameter.slack_notifications_webhook_url.value
    GPG_PASSPHRASE     = data.aws_ssm_parameter.gpg_passphrase.value
    GPG_PRIVATE_KEY    = data.aws_ssm_parameter.gpg_key.value
    SLACK_BOT_TOKEN    = data.aws_ssm_parameter.slack_bot_token.value
  }
}

module "github_aws_accounts_repository" {
  source          = "./tdr-terraform-modules/github_repositories"
  repository_name = "nationalarchives/tdr-aws-accounts"
  secrets = {
    MANAGEMENT_ACCOUNT = data.aws_ssm_parameter.mgmt_account_number.value
    SLACK_WEBHOOK      = data.aws_ssm_parameter.slack_webhook_url.value
    WORKFLOW_PAT       = module.common_ssm_parameters.params[local.github_access_token_name].value
  }
}

module "github_api_update_repository" {
  source          = "./tdr-terraform-modules/github_repositories"
  repository_name = "nationalarchives/tdr-api-update"
  secrets = {
    MANAGEMENT_ACCOUNT = data.aws_ssm_parameter.mgmt_account_number.value
    WORKFLOW_PAT       = module.common_ssm_parameters.params[local.github_access_token_name].value
    SLACK_WEBHOOK      = data.aws_ssm_parameter.slack_webhook_url.value
  }
}

module "github_export_authoriser_repository" {
  source          = "./tdr-terraform-modules/github_repositories"
  repository_name = "nationalarchives/tdr-consignment-export-authoriser"
  secrets = {
    MANAGEMENT_ACCOUNT = data.aws_ssm_parameter.mgmt_account_number.value
    WORKFLOW_PAT       = module.common_ssm_parameters.params[local.github_access_token_name].value
    SLACK_WEBHOOK      = data.aws_ssm_parameter.slack_webhook_url.value
  }
}

module "github_create_db_users_repository" {
  source          = "./tdr-terraform-modules/github_repositories"
  repository_name = "nationalarchives/tdr-create-db-users"
  secrets = {
    MANAGEMENT_ACCOUNT = data.aws_ssm_parameter.mgmt_account_number.value
    WORKFLOW_PAT       = module.common_ssm_parameters.params[local.github_access_token_name].value
    SLACK_WEBHOOK      = data.aws_ssm_parameter.slack_webhook_url.value
  }
}

module "github_export_status_update_repository" {
  source          = "./tdr-terraform-modules/github_repositories"
  repository_name = "nationalarchives/tdr-export-status-update"
  secrets = {
    MANAGEMENT_ACCOUNT = data.aws_ssm_parameter.mgmt_account_number.value
    WORKFLOW_PAT       = module.common_ssm_parameters.params[local.github_access_token_name].value
    SLACK_WEBHOOK      = data.aws_ssm_parameter.slack_webhook_url.value
  }
}

module "github_tna_custodian_repository" {
  source          = "./tdr-terraform-modules/github_repositories"
  repository_name = "nationalarchives/tna-custodian"
  secrets = {
    MANAGEMENT_ACCOUNT     = data.aws_ssm_parameter.mgmt_account_number.value
    WORKFLOW_PAT           = module.common_ssm_parameters.params[local.github_access_token_name].value
    SLACK_WEBHOOK          = data.aws_ssm_parameter.slack_webhook_url.value
    SANDBOX_ACCOUNT_NUMBER = data.aws_ssm_parameter.sandbox_account_number.value
  }
}

module "github_dev_documentation_repository" {
  source          = "./tdr-terraform-modules/github_repositories"
  repository_name = "nationalarchives/tdr-dev-documentation"
  secrets = {
    SLACK_WEBHOOK = data.aws_ssm_parameter.slack_webhook_url.value
  }
}

module "github_dev_documentation_internal_repository" {
  source          = "./tdr-terraform-modules/github_repositories"
  repository_name = "nationalarchives/tdr-dev-documentation-internal"
  secrets = {
    SLACK_WEBHOOK = data.aws_ssm_parameter.slack_webhook_url.value
  }
}

module "github_download_files_repository" {
  source          = "./tdr-terraform-modules/github_repositories"
  repository_name = "nationalarchives/tdr-download-files"
  secrets = {
    MANAGEMENT_ACCOUNT = data.aws_ssm_parameter.mgmt_account_number.value
    SLACK_WEBHOOK      = data.aws_ssm_parameter.slack_webhook_url.value
    WORKFLOW_PAT       = module.common_ssm_parameters.params[local.github_access_token_name].value
  }
}

module "github_ecr_scan_repository" {
  source          = "./tdr-terraform-modules/github_repositories"
  repository_name = "nationalarchives/tdr-ecr-scan"
  secrets = {
    MANAGEMENT_ACCOUNT = data.aws_ssm_parameter.mgmt_account_number.value
    SLACK_WEBHOOK      = data.aws_ssm_parameter.slack_webhook_url.value
    WORKFLOW_PAT       = module.common_ssm_parameters.params[local.github_access_token_name].value
  }
}

module "github_mgmt_lambda_policy" {
  source        = "./tdr-terraform-modules/iam_policy"
  name          = "TDRGithubLambdaPolicyMgmt"
  policy_string = templatefile("${path.module}/templates/iam_policy/github_mgmt_lambda_deploy.json.tpl", { account_id = data.aws_ssm_parameter.mgmt_account_number.value })
}

module "github_mgmt_lambda_role" {
  source             = "./tdr-terraform-modules/iam_role"
  assume_role_policy = templatefile("${path.module}/templates/iam_role/github_assume_role.json.tpl", { account_id = data.aws_ssm_parameter.mgmt_account_number.value, repo_name = "tdr-*" })
  common_tags        = local.common_tags
  name               = "TDRGithubActionsDeployLambdaMgmt"
  policy_attachments = {
    mgmt_lambda_policy = module.github_mgmt_lambda_policy.policy_arn
  }
}

module "github_ecr_scan_environment" {
  source          = "./tdr-terraform-modules/github_environments"
  environment     = "mgmt"
  repository_name = "nationalarchives/tdr-ecr-scan"
  team_slug       = "transfer-digital-records-admins"
}

module "github_file_format_repository" {
  source          = "./tdr-terraform-modules/github_repositories"
  repository_name = "nationalarchives/tdr-file-format"
  secrets = {
    MANAGEMENT_ACCOUNT = data.aws_ssm_parameter.mgmt_account_number.value
    SLACK_WEBHOOK      = data.aws_ssm_parameter.slack_webhook_url.value
    WORKFLOW_PAT       = module.common_ssm_parameters.params[local.github_access_token_name].value
  }
}

module "github_file_metadata_repository" {
  source          = "./tdr-terraform-modules/github_repositories"
  repository_name = "nationalarchives/tdr-file-metadata"
  secrets = {
    SLACK_WEBHOOK   = data.aws_ssm_parameter.slack_webhook_url.value
    WORKFLOW_PAT    = module.common_ssm_parameters.params[local.github_access_token_name].value
    NPM_TOKEN       = data.aws_ssm_parameter.npm_token.value
    GPG_PASSPHRASE  = data.aws_ssm_parameter.gpg_passphrase.value
    GPG_PRIVATE_KEY = data.aws_ssm_parameter.gpg_key.value
  }
}

module "github_grafana_repository" {
  source          = "./tdr-terraform-modules/github_repositories"
  repository_name = "nationalarchives/tdr-grafana"
  secrets = {
    MANAGEMENT_ACCOUNT = data.aws_ssm_parameter.mgmt_account_number.value
    SLACK_WEBHOOK      = data.aws_ssm_parameter.slack_webhook_url.value
    WORKFLOW_PAT       = module.common_ssm_parameters.params[local.github_access_token_name].value
  }
}

module "github_grafana_environment" {
  source                = "./tdr-terraform-modules/github_environments"
  environment           = "mgmt"
  repository_name       = "nationalarchives/tdr-grafana"
  team_slug             = "transfer-digital-records-admins"
  integration_team_slug = ["transfer-digital-records"]
}

module "github_notifications_repository" {
  source          = "./tdr-terraform-modules/github_repositories"
  repository_name = "nationalarchives/tdr-notifications"
  secrets = {
    MANAGEMENT_ACCOUNT = data.aws_ssm_parameter.mgmt_account_number.value
    SLACK_WEBHOOK      = data.aws_ssm_parameter.slack_webhook_url.value
    WORKFLOW_PAT       = module.common_ssm_parameters.params[local.github_access_token_name].value
  }
}

module "github_notifications_mgmt_environment" {
  source                = "./tdr-terraform-modules/github_environments"
  environment           = "mgmt"
  repository_name       = "nationalarchives/tdr-notifications"
  team_slug             = "transfer-digital-records-admins"
  integration_team_slug = ["transfer-digital-records"]
  secrets = {
    ACCOUNT_NUMBER = data.aws_ssm_parameter.mgmt_account_number.value
  }
}

module "github_pr_monitor_repository" {
  source          = "./tdr-terraform-modules/github_repositories"
  repository_name = "nationalarchives/pull-request-monitor"
  secrets = {
    SLACK_WEBHOOK = data.aws_ssm_parameter.slack_pr_monitor_url.value
    WORKFLOW_PAT  = module.common_ssm_parameters.params[local.github_access_token_name].value
  }
}

module "github_service_unavailable_repository" {
  source          = "./tdr-terraform-modules/github_repositories"
  repository_name = "nationalarchives/tdr-service-unavailable"
  secrets = {
    MANAGEMENT_ACCOUNT = data.aws_ssm_parameter.mgmt_account_number.value
    SLACK_WEBHOOK      = data.aws_ssm_parameter.slack_webhook_url.value
    WORKFLOW_PAT       = module.common_ssm_parameters.params[local.github_access_token_name].value
  }
}

module "github_signed_cookies_repository" {
  source          = "./tdr-terraform-modules/github_repositories"
  repository_name = "nationalarchives/tdr-signed-cookies"
  secrets = {
    MANAGEMENT_ACCOUNT = data.aws_ssm_parameter.mgmt_account_number.value
    SLACK_WEBHOOK      = data.aws_ssm_parameter.slack_webhook_url.value
    WORKFLOW_PAT       = module.common_ssm_parameters.params[local.github_access_token_name].value
  }
}

module "github_reporting_repository" {
  source          = "./tdr-terraform-modules/github_repositories"
  repository_name = "nationalarchives/tdr-reporting"
  collaborators   = module.global_parameters.collaborators
  secrets = {
    MANAGEMENT_ACCOUNT = data.aws_ssm_parameter.mgmt_account_number.value
    SLACK_WEBHOOK      = data.aws_ssm_parameter.slack_webhook_url.value
    WORKFLOW_PAT       = module.common_ssm_parameters.params[local.github_access_token_name].value
  }
}

module "github_rotate_keycloak_secrets_repository" {
  source          = "./tdr-terraform-modules/github_repositories"
  repository_name = "nationalarchives/tdr-rotate-keycloak-secrets"
  secrets = {
    MANAGEMENT_ACCOUNT = data.aws_ssm_parameter.mgmt_account_number.value
    SLACK_WEBHOOK      = data.aws_ssm_parameter.slack_webhook_url.value
    WORKFLOW_PAT       = module.common_ssm_parameters.params[local.github_access_token_name].value
  }
}

module "github_components_repository" {
  source          = "./tdr-terraform-modules/github_repositories"
  repository_name = "nationalarchives/tdr-components"
  secrets = {
    MANAGEMENT_ACCOUNT = data.aws_ssm_parameter.mgmt_account_number.value
    SLACK_WEBHOOK      = data.aws_ssm_parameter.slack_webhook_url.value
    WORKFLOW_PAT       = module.common_ssm_parameters.params[local.github_access_token_name].value
    NPM_TOKEN          = data.aws_ssm_parameter.npm_token.value
    GPG_PASSPHRASE     = data.aws_ssm_parameter.gpg_passphrase.value
    GPG_PRIVATE_KEY    = data.aws_ssm_parameter.gpg_key.value
  }
}

module "github_rotate_personal_access_token_event" {
  source                     = "./tdr-terraform-modules/cloudwatch_events"
  event_pattern              = "ssm_parameter_policy_action"
  sns_topic_event_target_arn = toset([module.notifications_topic.sns_arn])
  rule_name                  = "rotate-github-personal-access-token"
  rule_description           = "Notify to rotate github personal access token"
  event_variables            = { parameter_name = local.github_access_token_name, policy_type = "NoChangeNotification" }
}

module "github_file_upload_data_repository" {
  source          = "./tdr-terraform-modules/github_repositories"
  repository_name = "nationalarchives/tdr-file-upload-data"
  secrets = {
    MANAGEMENT_ACCOUNT = data.aws_ssm_parameter.mgmt_account_number.value
    SLACK_WEBHOOK      = data.aws_ssm_parameter.slack_webhook_url.value
    WORKFLOW_PAT       = module.common_ssm_parameters.params[local.github_access_token_name].value
  }
}
