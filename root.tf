locals {
  backend_state_bucket = "tdr-bootstrap-terraform-state"

  common_tags = tomap({
    "Owner"           = "TDR Backend", "Terraform" = true,
    "TerraformSource" = "https://github.com/nationalarchives/tdr-terraform-backend",
    "CostCentre"      = data.aws_ssm_parameter.cost_centre.value
  })

  github_tdr_e2e_tests_repository          = "repo:nationalarchives/tdr-e2e-tests:*"
  github_tdr_antivirus_repository          = "repo:nationalarchives/tdr-antivirus:*"
  github_da_reference_generator_repository = "repo:nationalarchives/da-reference-generator:*"

  terraform_state_bucket_access_roles = [
    module.github_terraform_assume_role_intg.role.arn, module.github_terraform_assume_role_staging.role.arn,
    module.github_terraform_assume_role_prod.role.arn, data.aws_ssm_parameter.mgmt_admin_role.value, local.aws_backup_local_role_arn
  ]

  aws_backup_role_name      = module.aws_backup_configuration.terraform_config["local_account_backup_role_name"]
  aws_backup_tag            = module.tdr_configuration.terraform_config["aws_backup_daily_short_term_retain_tag"]
  aws_backup_local_role_arn = "arn:aws:iam::${data.aws_ssm_parameter.mgmt_account_number.value}:role/${local.aws_backup_role_name}"
}

module "global_parameters" {
  source = "./tdr-configurations/terraform"
}

module "tdr_configuration" {
  source  = "./da-terraform-configurations"
  project = "tdr"
}

module "aws_backup_configuration" {
  source  = "./da-terraform-configurations"
  project = "aws-backup"
}

terraform {
  backend "s3" {
    bucket       = "tdr-bootstrap-terraform-state"
    key          = "terraform.state"
    region       = "eu-west-2"
    encrypt      = true
    use_lockfile = true
  }
}


//Management account AWS provider
provider "aws" {
  region = "eu-west-2"
}

//AWS providers for TDR environment accounts
provider "aws" {
  alias  = "intg"
  region = "eu-west-2"
  assume_role {
    role_arn     = "arn:aws:iam::${data.aws_ssm_parameter.intg_account_number.value}:role/IAM_Admin_Role"
    session_name = "terraform-backend"
  }
}

provider "aws" {
  alias  = "staging"
  region = "eu-west-2"
  assume_role {
    role_arn     = "arn:aws:iam::${data.aws_ssm_parameter.staging_account_number.value}:role/IAM_Admin_Role"
    session_name = "terraform-backend"
  }
}

provider "aws" {
  alias  = "prod"
  region = "eu-west-2"
  assume_role {
    role_arn     = "arn:aws:iam::${data.aws_ssm_parameter.prod_account_number.value}:role/IAM_Admin_Role"
    session_name = "terraform-backend"
  }
}

module "aws_sso_admin_role_ssm_parameters" {
  source = "./da-terraform-modules/ssm_parameter"
  parameters = [
    {
      name        = "/mgmt/admin_role",
      description = "AWS SSO admin role. Value to be added manually"
      type        = "SecureString"
      value       = "placeholder"
  }]
}

//Set up TDR environment roles to provide permissions for Terraform
module "intg_environment_roles" {
  source = "./modules/environment-roles"
  providers = {
    aws = aws.intg
  }

  tdr_environment                          = "intg"
  common_tags                              = local.common_tags
  tdr_mgmt_account_number                  = data.aws_ssm_parameter.mgmt_account_number.value
  sub_domain                               = "tdr-integration"
  terraform_external_id                    = module.global_parameters.external_ids.terraform_environments
  restore_db_external_id                   = module.global_parameters.external_ids.restore_db
  terraform_scripts_external_id            = module.global_parameters.external_ids.terraform_scripts
  grafana_management_external_id           = module.global_parameters.external_ids.grafana_management
  github_da_reference_generator_repository = local.github_da_reference_generator_repository
}

module "staging_environment_role" {
  source = "./modules/environment-roles"
  providers = {
    aws = aws.staging
  }

  tdr_environment                          = "staging"
  common_tags                              = local.common_tags
  tdr_mgmt_account_number                  = data.aws_ssm_parameter.mgmt_account_number.value
  sub_domain                               = "tdr-staging"
  terraform_external_id                    = module.global_parameters.external_ids.terraform_environments
  restore_db_external_id                   = module.global_parameters.external_ids.restore_db
  terraform_scripts_external_id            = module.global_parameters.external_ids.terraform_scripts
  grafana_management_external_id           = module.global_parameters.external_ids.grafana_management
  github_da_reference_generator_repository = local.github_da_reference_generator_repository
}

module "prod_environment_role" {
  source = "./modules/environment-roles"
  providers = {
    aws = aws.prod
  }

  tdr_environment                          = "prod"
  common_tags                              = local.common_tags
  tdr_mgmt_account_number                  = data.aws_ssm_parameter.mgmt_account_number.value
  sub_domain                               = "tdr"
  terraform_external_id                    = module.global_parameters.external_ids.terraform_environments
  restore_db_external_id                   = module.global_parameters.external_ids.restore_db
  terraform_scripts_external_id            = module.global_parameters.external_ids.terraform_scripts
  grafana_management_external_id           = module.global_parameters.external_ids.grafana_management
  github_da_reference_generator_repository = local.github_da_reference_generator_repository
}

//Shared parameters to store in each environment
module "intg_account_parameters" {
  source = "./modules/account-parameters"
  providers = {
    aws = aws.intg
  }

  common_tags = local.common_tags
  cost_centre = data.aws_ssm_parameter.cost_centre.value
}

module "staging_prod_account_parameters" {
  source = "./modules/account-parameters"
  providers = {
    aws = aws.prod
  }

  common_tags = local.common_tags
  cost_centre = data.aws_ssm_parameter.cost_centre.value
}

//Set up Terraform Backend state
module "terraform_state" {
  source                             = "./modules/state"
  terraform_state_bucket_kms_key_arn = module.terraform_state_bucket_kms_key.kms_key_arn

  common_tags               = local.common_tags
  aws_backup_local_role_arn = local.aws_backup_local_role_arn
  aws_backup_tag            = local.aws_backup_tag
}

//Set up Terraform Backend statelock
module "terraform_state_lock" {
  source = "./modules/state-lock"

  common_tags = local.common_tags
}

//Set up common IAM policies for Terraform
module "common_permissions" {
  source                         = "./modules/permissions"
  common_tags                    = local.common_tags
  terraform_state_bucket         = module.terraform_state.terraform_state_bucket_arn
  terraform_state_lock           = module.terraform_state_lock.terraform_state_lock_arn
  terraform_scripts_state_bucket = module.terraform_state.terraform_scripts_state_bucket_arn
  terraform_scripts_state_lock   = module.terraform_state_lock.terraform_scripts_state_lock_arn
  terraform_backend_state_bucket = data.aws_s3_bucket.state_bucket.arn
  terraform_github_state_bucket  = module.terraform_state.terraform_github_state_bucket_arn
  management_account_number      = data.aws_ssm_parameter.mgmt_account_number.value
  environment                    = "mgmt"
}

//Set up specific TDR environment IAM policies for Terraform
module "intg_specific_permissions" {
  source                                           = "./modules/specific-environment-permissions"
  common_tags                                      = local.common_tags
  terraform_state_bucket                           = module.terraform_state.terraform_state_bucket_arn
  terraform_state_lock                             = module.terraform_state_lock.terraform_state_lock_arn
  terraform_github_state_bucket                    = module.terraform_state.terraform_github_state_bucket_arn
  tdr_account_number                               = data.aws_ssm_parameter.intg_account_number.value
  tdr_mgmt_account_number                          = data.aws_ssm_parameter.mgmt_account_number.value
  tdr_environment                                  = "intg"
  read_terraform_state_policy_arn                  = module.common_permissions.read_terraform_state_policy_arn
  terraform_state_lock_access_arn                  = module.common_permissions.terraform_state_lock_access_arn
  terraform_describe_account_arn                   = module.common_permissions.terraform_describe_account_arn
  terraform_scripts_state_bucket                   = module.terraform_state.terraform_scripts_state_bucket_arn
  terraform_backend_state_bucket                   = data.aws_s3_bucket.state_bucket.arn
  terraform_state_bucket_encryption_key_policy_arn = module.terraform_state_bucket_kms_encryption_policy.policy_arn
}

module "staging_specific_permissions" {
  source                        = "./modules/specific-environment-permissions"
  common_tags                   = local.common_tags
  terraform_state_bucket        = module.terraform_state.terraform_state_bucket_arn
  terraform_state_lock          = module.terraform_state_lock.terraform_state_lock_arn
  terraform_github_state_bucket = module.terraform_state.terraform_github_state_bucket_arn
  #terraform_github_state_lock                      = module.terraform_state_lock.terraform_github_state_lock_arn
  tdr_account_number                               = data.aws_ssm_parameter.staging_account_number.value
  tdr_mgmt_account_number                          = data.aws_ssm_parameter.mgmt_account_number.value
  tdr_environment                                  = "staging"
  read_terraform_state_policy_arn                  = module.common_permissions.read_terraform_state_policy_arn
  terraform_state_lock_access_arn                  = module.common_permissions.terraform_state_lock_access_arn
  terraform_describe_account_arn                   = module.common_permissions.terraform_describe_account_arn
  terraform_scripts_state_bucket                   = module.terraform_state.terraform_scripts_state_bucket_arn
  terraform_backend_state_bucket                   = data.aws_s3_bucket.state_bucket.arn
  terraform_state_bucket_encryption_key_policy_arn = module.terraform_state_bucket_kms_encryption_policy.policy_arn
}

module "prod_specific_permissions" {
  source                                           = "./modules/specific-environment-permissions"
  common_tags                                      = local.common_tags
  terraform_state_bucket                           = module.terraform_state.terraform_state_bucket_arn
  terraform_state_lock                             = module.terraform_state_lock.terraform_state_lock_arn
  terraform_github_state_bucket                    = module.terraform_state.terraform_github_state_bucket_arn
  tdr_account_number                               = data.aws_ssm_parameter.prod_account_number.value
  tdr_mgmt_account_number                          = data.aws_ssm_parameter.mgmt_account_number.value
  tdr_environment                                  = "prod"
  read_terraform_state_policy_arn                  = module.common_permissions.read_terraform_state_policy_arn
  terraform_state_lock_access_arn                  = module.common_permissions.terraform_state_lock_access_arn
  terraform_describe_account_arn                   = module.common_permissions.terraform_describe_account_arn
  terraform_scripts_state_bucket                   = module.terraform_state.terraform_scripts_state_bucket_arn
  terraform_backend_state_bucket                   = data.aws_s3_bucket.state_bucket.arn
  terraform_state_bucket_encryption_key_policy_arn = module.terraform_state_bucket_kms_encryption_policy.policy_arn
}

module "sbox_specific_permissions" {
  source                                           = "./modules/specific-environment-permissions"
  common_tags                                      = local.common_tags
  terraform_state_bucket                           = module.terraform_state.terraform_state_bucket_arn
  terraform_state_lock                             = module.terraform_state_lock.terraform_state_lock_arn
  terraform_github_state_bucket                    = module.terraform_state.terraform_github_state_bucket_arn
  tdr_account_number                               = data.aws_ssm_parameter.sandbox_account_number.value
  tdr_mgmt_account_number                          = data.aws_ssm_parameter.mgmt_account_number.value
  tdr_environment                                  = "sbox"
  read_terraform_state_policy_arn                  = module.common_permissions.read_terraform_state_policy_arn
  terraform_state_lock_access_arn                  = module.common_permissions.terraform_state_lock_access_arn
  terraform_describe_account_arn                   = module.common_permissions.terraform_describe_account_arn
  terraform_scripts_state_bucket                   = module.terraform_state.terraform_scripts_state_bucket_arn
  add_ssm_policy                                   = true
  terraform_backend_state_bucket                   = data.aws_s3_bucket.state_bucket.arn
  terraform_state_bucket_encryption_key_policy_arn = module.terraform_state_bucket_kms_encryption_policy.policy_arn
}

module "backend_code_s3" {
  source        = "./tdr-terraform-modules/s3"
  project       = "tdr"
  function      = "backend-code"
  access_logs   = false
  common_tags   = local.common_tags
  bucket_policy = "lambda_update"
}

module "ecr_transfer_service_repository" {
  source           = "./da-terraform-modules/ecr"
  repository_name  = "transfer-service"
  image_source_url = "https://github.com/nationalarchives/tdr-transfer-service/blob/master/Dockerfile"
  allowed_principals = [
    "arn:aws:iam::${data.aws_ssm_parameter.intg_account_number.value}:role/TDRTransferServiceECSExecutionRoleIntg",
    "arn:aws:iam::${data.aws_ssm_parameter.staging_account_number.value}:role/TDRTransferServiceECSExecutionRoleStaging"
  ]
  common_tags = local.common_tags
}

module "ecr_draft_metadata_validator_repository" {
  source           = "./da-terraform-modules/ecr"
  repository_name  = "draft-metadata-validator"
  image_source_url = "https://github.com/nationalarchives/tdr-draft-metadata-validator/blob/main/Dockerfile"
  repository_policy = templatefile("${path.module}/templates/iam_policy/ecr_lambda_policy.json.tpl", {
    staging_account_number = data.aws_ssm_parameter.staging_account_number.value,
    prod_account_number    = data.aws_ssm_parameter.prod_account_number.value,
    intg_account_number    = data.aws_ssm_parameter.intg_account_number.value
  })
  common_tags = local.common_tags
}

module "ecr_consignment_api_repository" {
  source           = "./tdr-terraform-modules/ecr"
  name             = "consignment-api"
  image_source_url = "https://github.com/nationalarchives/tdr-consignment-api/blob/master/Dockerfile"
  policy_name      = "consignment_api_policy"
  policy_variables = {
    intg_account    = data.aws_ssm_parameter.intg_account_number.value,
    staging_account = data.aws_ssm_parameter.staging_account_number.value,
    prod_account    = data.aws_ssm_parameter.prod_account_number.value
  }
  common_tags = local.common_tags
}

module "ecr_transfer_frontend_repository" {
  source           = "./tdr-terraform-modules/ecr"
  name             = "transfer-frontend"
  image_source_url = "https://github.com/nationalarchives/tdr-transfer-frontend/blob/master/Dockerfile"
  policy_name      = "transfer_frontend_policy"
  policy_variables = {
    intg_account    = data.aws_ssm_parameter.intg_account_number.value,
    staging_account = data.aws_ssm_parameter.staging_account_number.value,
    prod_account    = data.aws_ssm_parameter.prod_account_number.value
  }
  common_tags = local.common_tags
}

module "ecr_collector_repository" {
  source           = "./tdr-terraform-modules/ecr"
  name             = "aws-otel-collector"
  image_source_url = "https://github.com/nationalarchives/tdr-xray-logging/blob/main/Dockerfile"
  policy_name      = "transfer_frontend_policy"
  policy_variables = {
    intg_account    = data.aws_ssm_parameter.intg_account_number.value,
    staging_account = data.aws_ssm_parameter.staging_account_number.value,
    prod_account    = data.aws_ssm_parameter.prod_account_number.value
  }
  common_tags = local.common_tags
}

module "ecr_auth_server_repository" {
  source           = "./tdr-terraform-modules/ecr"
  name             = "auth-server"
  image_source_url = "https://github.com/nationalarchives/tdr-auth-server/blob/master/Dockerfile"
  policy_name      = "auth_server_policy"
  policy_variables = {
    intg_account    = data.aws_ssm_parameter.intg_account_number.value,
    staging_account = data.aws_ssm_parameter.staging_account_number.value,
    prod_account    = data.aws_ssm_parameter.prod_account_number.value
  }
  common_tags = local.common_tags
}

module "ecr_consignment_export_repository" {
  source           = "./tdr-terraform-modules/ecr"
  name             = "consignment-export"
  image_source_url = "https://github.com/nationalarchives/tdr-consignment-export/blob/master/Dockerfile"
  policy_name      = "consignment_export_policy"
  policy_variables = {
    intg_account    = data.aws_ssm_parameter.intg_account_number.value,
    staging_account = data.aws_ssm_parameter.staging_account_number.value,
    prod_account    = data.aws_ssm_parameter.prod_account_number.value
  }
  common_tags = local.common_tags
}

module "ecr_api_data_repository" {
  source           = "./tdr-terraform-modules/ecr"
  name             = "consignment-api-data"
  image_source_url = "https://github.com/nationalarchives/tdr-consignment-api-data/blob/master/Dockerfile"
  policy_name      = "api_data_policy"
  policy_variables = {
    management_account = data.aws_ssm_parameter.mgmt_account_number.value,
    role_arn           = module.github_actions_role.role.arn
  }
  common_tags = local.common_tags
}

module "ecr_update_keycloak_repository" {
  source           = "./tdr-terraform-modules/ecr"
  name             = "keycloak-update"
  image_source_url = "https://github.com/nationalarchives/tdr-auth-server/blob/master/Dockerfile-update"
  policy_name      = "keycloak_update_policy"
  policy_variables = {
    intg_account    = data.aws_ssm_parameter.intg_account_number.value,
    staging_account = data.aws_ssm_parameter.staging_account_number.value,
    prod_account    = data.aws_ssm_parameter.prod_account_number.value
  }
  common_tags = local.common_tags
}

module "ecr_image_scan_log_group" {
  source      = "./tdr-terraform-modules/cloudwatch_logs"
  name        = "/aws/events/ecr-image-scans"
  common_tags = local.common_tags
}

module "ecr_image_scan_event" {
  source                     = "./tdr-terraform-modules/cloudwatch_events"
  event_pattern              = "ecr_image_scan"
  log_group_event_target_arn = module.ecr_image_scan_log_group.log_group_arn
  lambda_event_target_arn    = module.notification_lambda.ecr_scan_notification_lambda_arn
  rule_name                  = "ecr-image-scan"
  rule_description           = "Capture each ECR Image Scan"
}

module "notifications_topic" {
  source      = "./tdr-terraform-modules/sns"
  common_tags = local.common_tags
  function    = "notifications"
  project     = "tdr"
  sns_policy  = "notifications"
  kms_key_arn = module.mgmt_encryption_key.kms_key_arn
}

module "notification_lambda" {
  source                        = "./tdr-terraform-modules/lambda"
  common_tags                   = local.common_tags
  project                       = "tdr"
  lambda_ecr_scan_notifications = true
  event_rule_arns = [
    module.ecr_image_scan_event.event_arn,
    "arn:aws:events:eu-west-2:${data.aws_ssm_parameter.mgmt_account_number.value}:rule/jenkins-backup-maintenance-window"
  ]
  sns_topic_arns    = [module.notifications_topic.sns_arn]
  muted_scan_alerts = module.global_parameters.muted_ecr_scan_alerts
  kms_key_arn       = module.mgmt_encryption_key.kms_key_arn
  // value not needed for mgmt lambda but cipher text encrypted so cannot be an empty value
  da_event_bus_arn = "placeholder"
}

module "mgmt_encryption_key" {
  source                    = "./tdr-terraform-modules/kms"
  project                   = "tdr"
  function                  = "encryption"
  environment               = "mgmt"
  common_tags               = local.common_tags
  key_policy                = "cloudwatch"
  aws_backup_local_role_arn = local.aws_backup_local_role_arn
}

module "periodic_ecr_image_scan_lambda" {
  source                            = "./tdr-terraform-modules/lambda"
  common_tags                       = local.common_tags
  project                           = "tdr"
  lambda_ecr_scan                   = true
  periodic_ecr_image_scan_event_arn = module.periodic_ecr_image_scan_event.event_arn
}

module "periodic_ecr_image_scan_event" {
  source                  = "./tdr-terraform-modules/cloudwatch_events"
  schedule                = "rate(7 days)"
  rule_name               = "ecr-scan"
  lambda_event_target_arn = module.periodic_ecr_image_scan_lambda.ecr_scan_lambda_arn
}

module "terraform_state_bucket_kms_key" {
  source   = "./da-terraform-modules/kms"
  key_name = "tdr-terraform-state-mgmt"
  tags     = local.common_tags
  default_policy_variables = {
    user_roles = local.terraform_state_bucket_access_roles
    ci_roles   = [data.aws_ssm_parameter.mgmt_admin_role.value]
    service_details = [
      {
        service_name : "cloudwatch"
        service_source_account : data.aws_ssm_parameter.mgmt_account_number.value
      }
    ]
  }
}

module "terraform_state_bucket_kms_encryption_policy" {
  source        = "./da-terraform-modules/iam_policy"
  name          = "TDRTerraformStateBucketKMSEncryptionPolicy"
  policy_string = templatefile("${path.module}/templates/iam_policy/state_bucket_encryption_policy.json.tpl", { kms_key_arn = module.terraform_state_bucket_kms_key.kms_key_arn })
  tags          = local.common_tags
}
