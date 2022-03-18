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

module "github_terraform_environments_repository" {
  source          = "./tdr-terraform-modules/github_repositories"
  repository_name = "nationalarchives/tdr-terraform-environments"
  secrets = {
    MANAGEMENT_ACCOUNT = data.aws_ssm_parameter.mgmt_account_number.value
    SLACK_WEBHOOK      = data.aws_ssm_parameter.slack_webhook_url.value
    WORKFLOW_PAT       = data.aws_ssm_parameter.workflow_pat.value
  }
}

module "github_terraform_modules_repository" {
  source          = "./tdr-terraform-modules/github_repositories"
  repository_name = "nationalarchives/tdr-terraform-modules"
  secrets = {
    MANAGEMENT_ACCOUNT = data.aws_ssm_parameter.mgmt_account_number.value
    SLACK_WEBHOOK      = data.aws_ssm_parameter.slack_webhook_url.value
    WORKFLOW_PAT       = data.aws_ssm_parameter.workflow_pat.value
  }
}

module "github_cloudwatch_terraform_plan_outputs_intg" {
  source      = "../tdr-terraform-modules/cloudwatch_logs"
  common_tags = local.common_tags
  name        = "terraform-plan-outputs-intg"
}

module "github_cloudwatch_terraform_plan_outputs_staging" {
  source      = "../tdr-terraform-modules/cloudwatch_logs"
  common_tags = local.common_tags
  name        = "terraform-plan-outputs-staging"
}

module "github_cloudwatch_terraform_plan_outputs_prod" {
  source      = "../tdr-terraform-modules/cloudwatch_logs"
  common_tags = local.common_tags
  name        = "terraform-plan-outputs-prod"
}

module "github_cloudwatch_terraform_plan_policy" {
  source        = "./tdr-terraform-modules/iam_policy"
  name          = "TDRGithubCloudwatchTerraformPlanPolicy"
  policy_string = templatefile("${path.module}/templates/iam_policy/github_cloudwatch_policy.json.tpl", { account_id = data.aws_ssm_parameter.mgmt_account_number.value })
}

module "github_terraform_assume_role_intg" {
  source             = "./tdr-terraform-modules/iam_role"
  assume_role_policy = templatefile("${path.module}/templates/iam_role/github_assume_role.json.tpl", { account_id = data.aws_ssm_parameter.mgmt_account_number.value, repo_name = "tdr-terraform*" })
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
  assume_role_policy = templatefile("${path.module}/templates/iam_role/github_assume_role.json.tpl", { account_id = data.aws_ssm_parameter.mgmt_account_number.value, repo_name = "tdr-terraform*" })
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
  assume_role_policy = templatefile("${path.module}/templates/iam_role/github_assume_role.json.tpl", { account_id = data.aws_ssm_parameter.mgmt_account_number.value, repo_name = "tdr-terraform*" })
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
