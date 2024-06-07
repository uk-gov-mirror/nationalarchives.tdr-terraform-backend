module "configuration" {
  source  = "./da-terraform-configurations"
  project = "tdr"
}

module "run_e2e_tests_role" {
  source = "./tdr-terraform-modules/iam_role"
  assume_role_policy = templatefile("${path.module}/templates/iam_role/github_assume_role.json.tpl", {
    account_id = data.aws_ssm_parameter.mgmt_account_number.value,
    repo_names = jsonencode([local.github_tdr_e2e_tests_repository, local.github_tna_custodian_repository, local.github_da_reference_generator_repository])
  })
  common_tags        = local.common_tags
  name               = "TDRGithubActionsE2ETestsMgmt"
  policy_attachments = {}
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
  source = "./tdr-terraform-modules/iam_role"
  assume_role_policy = templatefile("${path.module}/templates/iam_role/github_assume_role.json.tpl", {
    account_id = data.aws_ssm_parameter.mgmt_account_number.value,
    repo_names = jsonencode(concat(module.global_parameters.github_tdr_active_repositories, [local.github_tna_custodian_repository, local.github_da_reference_generator_repository]))
  })
  common_tags = local.common_tags
  name        = "TDRGithubActionsRoleMgmt"
  policy_attachments = {
    dependencies = module.github_sbt_dependencies_policy.policy_arn,
    ecr          = module.github_ecr_policy.policy_arn
    backend_code = module.github_actions_code_bucket_policy.policy_arn
  }
}

module "github_oidc_provider" {
  source          = "./tdr-terraform-modules/identity_provider"
  audience        = "sts.amazonaws.com"
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1", "1c58a3a8518e8759bf075b76b750d4f2df264fcd"]
  url             = "https://token.actions.githubusercontent.com"
  common_tags     = local.common_tags
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
  source = "./tdr-terraform-modules/iam_role"
  assume_role_policy = templatefile("${path.module}/templates/iam_role/github_assume_role.json.tpl", {
    account_id = data.aws_ssm_parameter.mgmt_account_number.value,
    repo_names = jsonencode(concat(module.global_parameters.github_tdr_active_repositories, [local.github_tna_custodian_repository, local.github_da_reference_generator_repository]))
  })
  common_tags = local.common_tags
  name        = "TDRGithubTerraformAssumeRoleIntg"
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
  source = "./tdr-terraform-modules/iam_role"
  assume_role_policy = templatefile("${path.module}/templates/iam_role/github_assume_role.json.tpl", {
    account_id = data.aws_ssm_parameter.mgmt_account_number.value,
    repo_names = jsonencode(concat(module.global_parameters.github_tdr_active_repositories, [local.github_tna_custodian_repository, local.github_da_reference_generator_repository]))
  })
  common_tags = local.common_tags
  name        = "TDRGithubTerraformAssumeRoleStaging"
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
  source = "./tdr-terraform-modules/iam_role"
  assume_role_policy = templatefile("${path.module}/templates/iam_role/github_assume_role.json.tpl", {
    account_id = data.aws_ssm_parameter.mgmt_account_number.value,
    repo_names = jsonencode(concat(module.global_parameters.github_tdr_active_repositories, [local.github_tna_custodian_repository, local.github_da_reference_generator_repository]))
  })
  common_tags = local.common_tags
  name        = "TDRGithubTerraformAssumeRoleProd"
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
  source = "./tdr-terraform-modules/iam_role"
  assume_role_policy = templatefile("${path.module}/templates/iam_role/github_assume_role.json.tpl", {
    account_id = data.aws_ssm_parameter.mgmt_account_number.value,
    repo_names = jsonencode(concat(module.global_parameters.github_tdr_active_repositories, [local.github_tna_custodian_repository, local.github_da_reference_generator_repository]))
  })
  common_tags = local.common_tags
  name        = "TDRGithubTerraformAssumeRoleSbox"
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

module "github_antivirus_rule_checks_policy" {
  source        = "./tdr-terraform-modules/iam_policy"
  name          = "TDRGithubAvRuleChecksPolicyMgmt"
  policy_string = templatefile("${path.module}/templates/iam_policy/github_av_rule_checks.json.tpl", {})
}

module "github_antivirus_rule_checks" {
  source = "./tdr-terraform-modules/iam_role"
  assume_role_policy = templatefile("${path.module}/templates/iam_role/github_assume_role.json.tpl", {
    account_id = data.aws_ssm_parameter.mgmt_account_number.value,
    repo_names = jsonencode([local.github_tdr_antivirus_repository, local.github_tna_custodian_repository, local.github_da_reference_generator_repository]))
  })
  common_tags = local.common_tags
  name        = "TDRGithubAvRuleChecksMgmt"
  policy_attachments = {
    av_rule_check_policy = module.github_antivirus_rule_checks_policy.policy_arn
  }
}


module "github_mgmt_lambda_policy" {
  source        = "./tdr-terraform-modules/iam_policy"
  name          = "TDRGithubLambdaPolicyMgmt"
  policy_string = templatefile("${path.module}/templates/iam_policy/github_mgmt_lambda_deploy.json.tpl", { account_id = data.aws_ssm_parameter.mgmt_account_number.value })
}

module "github_mgmt_lambda_role" {
  source = "./tdr-terraform-modules/iam_role"
  assume_role_policy = templatefile("${path.module}/templates/iam_role/github_assume_role.json.tpl", {
    account_id = data.aws_ssm_parameter.mgmt_account_number.value,
    repo_names = jsonencode(concat(module.global_parameters.github_tdr_active_repositories, [local.github_tna_custodian_repository, local.github_da_reference_generator_repository]))
  })
  common_tags = local.common_tags
  name        = "TDRGithubActionsDeployLambdaMgmt"
  policy_attachments = {
    mgmt_lambda_policy = module.github_mgmt_lambda_policy.policy_arn
  }
}
