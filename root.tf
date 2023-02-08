locals {
  backend_state_lock   = "tdr-bootstrap-terraform-state-lock"
  backend_state_bucket = "tdr-bootstrap-terraform-state"
  common_tags = tomap(
    {
      "Owner"           = "TDR Backend",
      "Terraform"       = true,
      "TerraformSource" = "https://github.com/nationalarchives/tdr-terraform-backend",
      "CostCentre"      = data.aws_ssm_parameter.cost_centre.value
    }
  )
  github_access_token_name = "/mgmt/github/access_token"
}

module "common_ssm_parameters" {
  source      = "./tdr-terraform-modules/ssm_parameter"
  common_tags = local.common_tags
  random_parameters = [
    {
      name = local.github_access_token_name, description = "The GitHub workflow token", value = "to_be_manually_added", type = "SecureString", tier = "Advanced"
    }
  ]
}

module "global_parameters" {
  source = "./tdr-configurations/terraform"
}

terraform {
  backend "s3" {
    bucket         = "tdr-bootstrap-terraform-state"
    key            = "terraform.state"
    region         = "eu-west-2"
    encrypt        = true
    dynamodb_table = "tdr-bootstrap-terraform-state-lock"
  }
}

//Management account AWS provider
provider "aws" {
  region  = "eu-west-2"
  profile = "management"
}

//AWS providers for TDR environment accounts
provider "aws" {
  alias   = "intg"
  region  = "eu-west-2"
  profile = "management"
  assume_role {
    role_arn     = "arn:aws:iam::${data.aws_ssm_parameter.intg_account_number.value}:role/IAM_Admin_Role"
    session_name = "terraform-backend"
  }
}

provider "aws" {
  alias   = "staging"
  region  = "eu-west-2"
  profile = "management"
  assume_role {
    role_arn     = "arn:aws:iam::${data.aws_ssm_parameter.staging_account_number.value}:role/IAM_Admin_Role"
    session_name = "terraform-backend"
  }
}

provider "aws" {
  alias   = "prod"
  region  = "eu-west-2"
  profile = "management"
  assume_role {
    role_arn     = "arn:aws:iam::${data.aws_ssm_parameter.prod_account_number.value}:role/IAM_Admin_Role"
    session_name = "terraform-backend"
  }
}

//Set up TDR environment roles to provide permissions for Terraform
module "intg_environment_roles" {
  source = "./modules/environment-roles"
  providers = {
    aws = aws.intg
  }

  tdr_environment                = "intg"
  common_tags                    = local.common_tags
  tdr_mgmt_account_number        = data.aws_ssm_parameter.mgmt_account_number.value
  sub_domain                     = "tdr-integration"
  terraform_external_id          = module.global_parameters.external_ids.terraform_environments
  restore_db_external_id         = module.global_parameters.external_ids.restore_db
  terraform_scripts_external_id  = module.global_parameters.external_ids.terraform_scripts
  grafana_management_external_id = module.global_parameters.external_ids.grafana_management
}

module "staging_environment_role" {
  source = "./modules/environment-roles"
  providers = {
    aws = aws.staging
  }

  tdr_environment                = "staging"
  common_tags                    = local.common_tags
  tdr_mgmt_account_number        = data.aws_ssm_parameter.mgmt_account_number.value
  sub_domain                     = "tdr-staging"
  terraform_external_id          = module.global_parameters.external_ids.terraform_environments
  restore_db_external_id         = module.global_parameters.external_ids.restore_db
  terraform_scripts_external_id  = module.global_parameters.external_ids.terraform_scripts
  grafana_management_external_id = module.global_parameters.external_ids.grafana_management
}

module "prod_environment_role" {
  source = "./modules/environment-roles"
  providers = {
    aws = aws.prod
  }

  tdr_environment                = "prod"
  common_tags                    = local.common_tags
  tdr_mgmt_account_number        = data.aws_ssm_parameter.mgmt_account_number.value
  sub_domain                     = "tdr"
  terraform_external_id          = module.global_parameters.external_ids.terraform_environments
  restore_db_external_id         = module.global_parameters.external_ids.restore_db
  terraform_scripts_external_id  = module.global_parameters.external_ids.terraform_scripts
  grafana_management_external_id = module.global_parameters.external_ids.grafana_management
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
  source = "./modules/state"

  common_tags = local.common_tags
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
  terraform_scripts_state_lock   = module.terraform_state_lock.terraform_scripts_state_lock_arn
  terraform_backend_state_bucket = data.aws_s3_bucket.state_bucket.arn
  terraform_backend_state_lock   = data.aws_dynamodb_table.state_lock_table.arn
  terraform_scripts_state_bucket = module.terraform_state.terraform_scripts_state_bucket_arn
  management_account_number      = data.aws_ssm_parameter.mgmt_account_number.value
  environment                    = "mgmt"
}

//Set up specific TDR environment IAM policies for Terraform
module "intg_specific_permissions" {
  source                          = "./modules/specific-environment-permissions"
  common_tags                     = local.common_tags
  terraform_state_bucket          = module.terraform_state.terraform_state_bucket_arn
  terraform_state_lock            = module.terraform_state_lock.terraform_state_lock_arn
  tdr_account_number              = data.aws_ssm_parameter.intg_account_number.value
  tdr_mgmt_account_number         = data.aws_ssm_parameter.mgmt_account_number.value
  tdr_environment                 = "intg"
  read_terraform_state_policy_arn = module.common_permissions.read_terraform_state_policy_arn
  terraform_state_lock_access_arn = module.common_permissions.terraform_state_lock_access_arn
  terraform_describe_account_arn  = module.common_permissions.terraform_describe_account_arn
  custodian_get_parameters_arn    = module.common_permissions.custodian_get_parameters_arn
  terraform_scripts_state_bucket  = module.terraform_state.terraform_scripts_state_bucket_arn
  terraform_backend_state_bucket  = data.aws_s3_bucket.state_bucket.arn
}

module "staging_specific_permissions" {
  source                          = "./modules/specific-environment-permissions"
  common_tags                     = local.common_tags
  terraform_state_bucket          = module.terraform_state.terraform_state_bucket_arn
  terraform_state_lock            = module.terraform_state_lock.terraform_state_lock_arn
  tdr_account_number              = data.aws_ssm_parameter.staging_account_number.value
  tdr_mgmt_account_number         = data.aws_ssm_parameter.mgmt_account_number.value
  tdr_environment                 = "staging"
  read_terraform_state_policy_arn = module.common_permissions.read_terraform_state_policy_arn
  terraform_state_lock_access_arn = module.common_permissions.terraform_state_lock_access_arn
  terraform_describe_account_arn  = module.common_permissions.terraform_describe_account_arn
  custodian_get_parameters_arn    = module.common_permissions.custodian_get_parameters_arn
  terraform_scripts_state_bucket  = module.terraform_state.terraform_scripts_state_bucket_arn
  terraform_backend_state_bucket  = data.aws_s3_bucket.state_bucket.arn
}

module "prod_specific_permissions" {
  source                          = "./modules/specific-environment-permissions"
  common_tags                     = local.common_tags
  terraform_state_bucket          = module.terraform_state.terraform_state_bucket_arn
  terraform_state_lock            = module.terraform_state_lock.terraform_state_lock_arn
  tdr_account_number              = data.aws_ssm_parameter.prod_account_number.value
  tdr_mgmt_account_number         = data.aws_ssm_parameter.mgmt_account_number.value
  tdr_environment                 = "prod"
  read_terraform_state_policy_arn = module.common_permissions.read_terraform_state_policy_arn
  terraform_state_lock_access_arn = module.common_permissions.terraform_state_lock_access_arn
  terraform_describe_account_arn  = module.common_permissions.terraform_describe_account_arn
  custodian_get_parameters_arn    = module.common_permissions.custodian_get_parameters_arn
  terraform_scripts_state_bucket  = module.terraform_state.terraform_scripts_state_bucket_arn
  terraform_backend_state_bucket  = data.aws_s3_bucket.state_bucket.arn
}

module "sbox_specific_permissions" {
  source                          = "./modules/specific-environment-permissions"
  common_tags                     = local.common_tags
  terraform_state_bucket          = module.terraform_state.terraform_state_bucket_arn
  terraform_state_lock            = module.terraform_state_lock.terraform_state_lock_arn
  tdr_account_number              = data.aws_ssm_parameter.sandbox_account_number.value
  tdr_mgmt_account_number         = data.aws_ssm_parameter.mgmt_account_number.value
  tdr_environment                 = "sbox"
  read_terraform_state_policy_arn = module.common_permissions.read_terraform_state_policy_arn
  terraform_state_lock_access_arn = module.common_permissions.terraform_state_lock_access_arn
  terraform_describe_account_arn  = module.common_permissions.terraform_describe_account_arn
  custodian_get_parameters_arn    = module.common_permissions.custodian_get_parameters_arn
  terraform_scripts_state_bucket  = module.terraform_state.terraform_scripts_state_bucket_arn
  add_ssm_policy                  = true
  terraform_backend_state_bucket  = data.aws_s3_bucket.state_bucket.arn
}

module "backend_code_s3" {
  source        = "./tdr-terraform-modules/s3"
  project       = "tdr"
  function      = "backend-code"
  access_logs   = false
  common_tags   = local.common_tags
  bucket_policy = "lambda_update"
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
  policy_variables = { management_account = data.aws_ssm_parameter.mgmt_account_number.value, role_arn = module.github_actions_role.role.arn }
  common_tags      = local.common_tags
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
  event_rule_arns               = [module.ecr_image_scan_event.event_arn, "arn:aws:events:eu-west-2:${data.aws_ssm_parameter.mgmt_account_number.value}:rule/jenkins-backup-maintenance-window"]
  sns_topic_arns                = [module.notifications_topic.sns_arn]
  muted_scan_alerts             = module.global_parameters.muted_ecr_scan_alerts
  kms_key_arn                   = module.mgmt_encryption_key.kms_key_arn
}

module "mgmt_encryption_key" {
  source      = "./tdr-terraform-modules/kms"
  project     = "tdr"
  function    = "encryption"
  environment = "mgmt"
  common_tags = local.common_tags
  key_policy  = "cloudwatch"
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
