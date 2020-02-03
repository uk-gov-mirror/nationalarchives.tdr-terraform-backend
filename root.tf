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
}

module "staging_environment_role" {
  source = "./modules/environment-roles"
  providers = {
    aws = aws.staging
  }

  tdr_environment         = "staging"
  common_tags             = local.common_tags
  tdr_mgmt_account_number = data.aws_ssm_parameter.mgmt_account_number.value
}

module "prod_environment_role" {
  source = "./modules/environment-roles"
  providers = {
    aws = aws.prod
  }

  tdr_environment         = "prod"
  common_tags             = local.common_tags
  tdr_mgmt_account_number = data.aws_ssm_parameter.mgmt_account_number.value
}

//Shared parameters to store in each environment
module "intg_environment_parameters" {
  source = "./modules/environment-parameters"
  providers = {
    aws = aws.intg
  }

  common_tags     = local.common_tags
  cost_centre     = data.aws_ssm_parameter.cost_centre.value
}

module "staging_environment_parameters" {
  source = "./modules/environment-parameters"
  providers = {
    aws = aws.staging
  }

  common_tags     = local.common_tags
  cost_centre     = data.aws_ssm_parameter.cost_centre.value
}

module "prod_environment_parameters" {
  source = "./modules/environment-parameters"
  providers = {
    aws = aws.prod
  }

  common_tags     = local.common_tags
  cost_centre     = data.aws_ssm_parameter.cost_centre.value
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
module "terraform_permissions" {
  source                 = "./modules/permissions"
  common_tags            = local.common_tags
  terraform_state_bucket = module.terraform_state.terraform_state_bucket_arn
  terraform_state_lock   = module.terraform_state_lock.terraform_state_lock_arn
}

//Set up specific TDR environment IAM policies for Terraform
module "intg_specific_permissions" {
  source                          = "./modules/specific-environment-permissions"
  common_tags                     = local.common_tags
  terraform_state_bucket          = module.terraform_state.terraform_state_bucket_arn
  terraform_state_lock            = module.terraform_state_lock.terraform_state_lock_arn
  tdr_account_number              = data.aws_ssm_parameter.intg_account_number.value
  tdr_environment                 = "intg"
  read_terraform_state_policy_arn = module.terraform_permissions.read_terraform_state_policy_arn
  terraform_state_lock_access_arn = module.terraform_permissions.terraform_state_lock_access_arn
  terraform_describe_account_arn  = module.terraform_permissions.terraform_describe_account_arn
}

module "staging_specific_permissions" {
  source                          = "./modules/specific-environment-permissions"
  common_tags                     = local.common_tags
  terraform_state_bucket          = module.terraform_state.terraform_state_bucket_arn
  terraform_state_lock            = module.terraform_state_lock.terraform_state_lock_arn
  tdr_account_number              = data.aws_ssm_parameter.staging_account_number.value
  tdr_environment                 = "staging"
  read_terraform_state_policy_arn = module.terraform_permissions.read_terraform_state_policy_arn
  terraform_state_lock_access_arn = module.terraform_permissions.terraform_state_lock_access_arn
  terraform_describe_account_arn  = module.terraform_permissions.terraform_describe_account_arn
}

module "prod_specific_permissions" {
  source                          = "./modules/specific-environment-permissions"
  common_tags                     = local.common_tags
  terraform_state_bucket          = module.terraform_state.terraform_state_bucket_arn
  terraform_state_lock            = module.terraform_state_lock.terraform_state_lock_arn
  tdr_account_number              = data.aws_ssm_parameter.prod_account_number.value
  tdr_environment                 = "prod"
  read_terraform_state_policy_arn = module.terraform_permissions.read_terraform_state_policy_arn
  terraform_state_lock_access_arn = module.terraform_permissions.terraform_state_lock_access_arn
  terraform_describe_account_arn  = module.terraform_permissions.terraform_describe_account_arn
}

//Set up Jenkins permissions
module "jenkins_permissions" {
  source                         = "./modules/jenkins"
  environment                    = "mgmt"
  terraform_jenkins_state_bucket = module.terraform_state.terraform_jenkins_state_bucket
  terraform_jenkins_state_lock   = module.terraform_state_lock.terraform_jenkins_state_lock
}
