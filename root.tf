locals {
  common_tags = map(
    "Owner", "TDR Backend",
    "Terraform", true,
    "CostCentre", data.aws_ssm_parameter.cost_centre.value
  )
}

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

data "aws_ssm_parameter" "cost_centre" {
  name = "/mgmt/cost_centre"
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

  tdr_environment         = "intg"
  common_tags             = local.common_tags
  tdr_mgmt_account_number = data.aws_ssm_parameter.mgmt_account_number.value
  sub_domain              = "tdr-integration"
}

module "staging_environment_role" {
  source = "./modules/environment-roles"
  providers = {
    aws = aws.staging
  }

  tdr_environment         = "staging"
  common_tags             = local.common_tags
  tdr_mgmt_account_number = data.aws_ssm_parameter.mgmt_account_number.value
  sub_domain              = "tdr-staging"
}

module "prod_environment_role" {
  source = "./modules/environment-roles"
  providers = {
    aws = aws.prod
  }

  tdr_environment         = "prod"
  common_tags             = local.common_tags
  tdr_mgmt_account_number = data.aws_ssm_parameter.mgmt_account_number.value
  sub_domain              = "tdr"
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

//Set up common IAM policies for Terraform and for publishing to S3
module "common_permissions" {
  source                         = "./modules/permissions"
  common_tags                    = local.common_tags
  terraform_state_bucket         = module.terraform_state.terraform_state_bucket_arn
  terraform_state_lock           = module.terraform_state_lock.terraform_state_lock_arn
  terraform_scripts_state_lock   = module.terraform_state_lock.terraform_scripts_state_lock_arn
  release_bucket_arn             = module.release_artefacts_s3.s3_bucket_arn
  staging_bucket_arn             = module.staging_artefacts_s3.s3_bucket_arn
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
  tdr_environment                 = "intg"
  read_terraform_state_policy_arn = module.common_permissions.read_terraform_state_policy_arn
  terraform_state_lock_access_arn = module.common_permissions.terraform_state_lock_access_arn
  terraform_describe_account_arn  = module.common_permissions.terraform_describe_account_arn
  custodian_get_parameters_arn    = module.common_permissions.custodian_get_parameters_arn
  terraform_scripts_state_bucket  = module.terraform_state.terraform_scripts_state_bucket_arn
}

module "staging_specific_permissions" {
  source                          = "./modules/specific-environment-permissions"
  common_tags                     = local.common_tags
  terraform_state_bucket          = module.terraform_state.terraform_state_bucket_arn
  terraform_state_lock            = module.terraform_state_lock.terraform_state_lock_arn
  tdr_account_number              = data.aws_ssm_parameter.staging_account_number.value
  tdr_environment                 = "staging"
  read_terraform_state_policy_arn = module.common_permissions.read_terraform_state_policy_arn
  terraform_state_lock_access_arn = module.common_permissions.terraform_state_lock_access_arn
  terraform_describe_account_arn  = module.common_permissions.terraform_describe_account_arn
  custodian_get_parameters_arn    = module.common_permissions.custodian_get_parameters_arn
  terraform_scripts_state_bucket  = module.terraform_state.terraform_scripts_state_bucket_arn
}

module "prod_specific_permissions" {
  source                          = "./modules/specific-environment-permissions"
  common_tags                     = local.common_tags
  terraform_state_bucket          = module.terraform_state.terraform_state_bucket_arn
  terraform_state_lock            = module.terraform_state_lock.terraform_state_lock_arn
  tdr_account_number              = data.aws_ssm_parameter.prod_account_number.value
  tdr_environment                 = "prod"
  read_terraform_state_policy_arn = module.common_permissions.read_terraform_state_policy_arn
  terraform_state_lock_access_arn = module.common_permissions.terraform_state_lock_access_arn
  terraform_describe_account_arn  = module.common_permissions.terraform_describe_account_arn
  custodian_get_parameters_arn    = module.common_permissions.custodian_get_parameters_arn
  terraform_scripts_state_bucket  = module.terraform_state.terraform_scripts_state_bucket_arn
}

//Set up Jenkins permissions
module "jenkins_permissions" {
  source                         = "./modules/jenkins"
  environment                    = "mgmt"
  terraform_jenkins_state_bucket = module.terraform_state.terraform_jenkins_state_bucket
  terraform_jenkins_state_lock   = module.terraform_state_lock.terraform_jenkins_state_lock
}

//Set up Grafana permissions
module "grafana_permissions" {
  source = "./modules/grafana"

  common_tags                    = local.common_tags
  tdr_environment                = "mgmt"
  tdr_mgmt_account_number        = data.aws_ssm_parameter.mgmt_account_number.value
  terraform_grafana_state_bucket = module.terraform_state.terraform_grafana_state_bucket_arn
  terraform_grafana_state_lock   = module.terraform_state_lock.terraform_grafana_state_lock_arn
}

module "release_artefacts_s3" {
  source      = "./tdr-terraform-modules/s3"
  project     = "tdr"
  function    = "releases"
  access_logs = false
  common_tags = local.common_tags
}

module "staging_artefacts_s3" {
  source      = "./tdr-terraform-modules/s3"
  project     = "tdr"
  function    = "snapshots"
  access_logs = false
  common_tags = local.common_tags
}

module "backend_code_s3" {
  source        = "./tdr-terraform-modules/s3"
  project       = "tdr"
  function      = "backend-code"
  access_logs   = false
  common_tags   = local.common_tags
  bucket_policy = "lambda_update"
}

module "ecr_yara_repository" {
  source           = "./tdr-terraform-modules/ecr"
  name             = "yara"
  image_source_url = "https://github.com/nationalarchives/tdr-antivirus/blob/master/Dockerfile-yara"
  common_tags      = local.common_tags
}

module "ecr_dependencies_repository" {
  source           = "./tdr-terraform-modules/ecr"
  name             = "yara-dependencies"
  image_source_url = "https://github.com/nationalarchives/tdr-antivirus/blob/master/Dockerfile-dependencies"
  common_tags      = local.common_tags
}

module "ecr_rules_repository" {
  source           = "./tdr-terraform-modules/ecr"
  name             = "yara-rules"
  image_source_url = "https://github.com/nationalarchives/tdr-antivirus/blob/master/Dockerfile-compile"
  common_tags      = local.common_tags
}

module "ecr_consignment_api_repository" {
  source           = "./tdr-terraform-modules/ecr"
  name             = "consignment-api"
  image_source_url = "https://github.com/nationalarchives/tdr-consignment-api/blob/master/Dockerfile"
  policy_name      = "consignment_api_policy"
  policy_variables = { intg_account = data.aws_ssm_parameter.intg_account_number.value, staging_account = data.aws_ssm_parameter.staging_account_number.value, prod_account = data.aws_ssm_parameter.prod_account_number.value }
  common_tags      = local.common_tags
}

module "ecr_transfer_frontend_repository" {
  source           = "./tdr-terraform-modules/ecr"
  name             = "transfer-frontend"
  image_source_url = "https://github.com/nationalarchives/tdr-transfer-frontend/blob/master/Dockerfile"
  policy_name      = "transfer_frontend_policy"
  policy_variables = { intg_account = data.aws_ssm_parameter.intg_account_number.value, staging_account = data.aws_ssm_parameter.staging_account_number.value, prod_account = data.aws_ssm_parameter.prod_account_number.value }
  common_tags      = local.common_tags
}

module "ecr_auth_server_repository" {
  source           = "./tdr-terraform-modules/ecr"
  name             = "auth-server"
  image_source_url = "https://github.com/nationalarchives/tdr-auth-server/blob/master/Dockerfile"
  policy_name      = "auth_server_policy"
  policy_variables = { intg_account = data.aws_ssm_parameter.intg_account_number.value, staging_account = data.aws_ssm_parameter.staging_account_number.value, prod_account = data.aws_ssm_parameter.prod_account_number.value }
  common_tags      = local.common_tags
}

module "ecr_file_format_build_repository" {
  source           = "./tdr-terraform-modules/ecr"
  name             = "file-format-build"
  image_source_url = "https://github.com/nationalarchives/tdr-file-format/blob/master/Dockerfile"
  policy_name      = "file_format_policy"
  policy_variables = { intg_account = data.aws_ssm_parameter.intg_account_number.value, staging_account = data.aws_ssm_parameter.staging_account_number.value, prod_account = data.aws_ssm_parameter.prod_account_number.value }
  common_tags      = local.common_tags
}

module "ecr_consignment_export_repository" {
  source           = "./tdr-terraform-modules/ecr"
  name             = "consignment-export"
  image_source_url = "https://github.com/nationalarchives/tdr-consignment-export/blob/master/Dockerfile"
  policy_name      = "consignment_export_policy"
  policy_variables = { intg_account = data.aws_ssm_parameter.intg_account_number.value, staging_account = data.aws_ssm_parameter.staging_account_number.value, prod_account = data.aws_ssm_parameter.prod_account_number.value }
  common_tags      = local.common_tags
}

module "ecr_image_scan_log_group" {
  source = "./tdr-terraform-modules/cloudwatch_logs"
  name   = "/aws/events/ecr-image-scans"
}

module "ecr_image_scan_event" {
  source                     = "./tdr-terraform-modules/cloudwatch_events"
  event_pattern              = "ecr_image_scan"
  log_group_event_target_arn = module.ecr_image_scan_log_group.log_group_arn
  lambda_event_target_arn    = module.notification_lambda.ecr_scan_notification_lambda_arn
  rule_name                  = "ecr-image-scan"
  rule_description           = "Capture each ECR Image Scan"
}

module "notification_lambda" {
  source                        = "./tdr-terraform-modules/lambda"
  common_tags                   = local.common_tags
  project                       = "tdr"
  lambda_ecr_scan_notifications = true
  event_rule_arns               = [module.ecr_image_scan_event.event_arn, "arn:aws:events:eu-west-2:${data.aws_ssm_parameter.mgmt_account_number.value}:rule/jenkins-backup-maintenance-window"]
  sns_topic_arns                = ["arn:aws:sns:eu-west-2:${data.aws_ssm_parameter.intg_account_number.value}:tdr-notifications-intg", "arn:aws:sns:eu-west-2:${data.aws_ssm_parameter.staging_account_number.value}:tdr-notifications-staging", "arn:aws:sns:eu-west-2:${data.aws_ssm_parameter.prod_account_number.value}:tdr-notifications-prod"]
  muted_scan_alerts             = module.global_parameters.muted_ecr_scan_alerts
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
