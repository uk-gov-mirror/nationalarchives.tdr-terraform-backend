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
    WORKFLOW_PAT       = data.aws_ssm_parameter.workflow_pat.value
    SLACK_WEBHOOK      = data.aws_ssm_parameter.slack_webhook_url.value
  }
}

module "github_consignment_api_repository" {
  source          = "./tdr-terraform-modules/github_repositories"
  repository_name = "nationalarchives/tdr-consignment-api"
  secrets = {
    MANAGEMENT_ACCOUNT = data.aws_ssm_parameter.mgmt_account_number.value
    WORKFLOW_PAT       = data.aws_ssm_parameter.workflow_pat.value
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
    WORKFLOW_PAT       = data.aws_ssm_parameter.workflow_pat.value
  }
}

module "github_generated_grapqhl_environment" {
  source          = "./tdr-terraform-modules/github_repositories"
  repository_name = "nationalarchives/tdr-generated-graphql"
  secrets = {
    WORKFLOW_PAT      = data.aws_ssm_parameter.workflow_pat.value
    NPM_TOKEN         = data.aws_ssm_parameter.npm_token.value
    SLACK_WEBHOOK     = data.aws_ssm_parameter.slack_webhook_url.value
    GPG_PASSPHRASE    = data.aws_ssm_parameter.gpg_passphrase.value
    GPG_PRIVATE_KEY   = data.aws_ssm_parameter.gpg_key.value
    SONATYPE_USERNAME = data.aws_ssm_parameter.sonatype_username.value
    SONATYPE_PASSWORD = data.aws_ssm_parameter.sonatype_password.value
  }
}
