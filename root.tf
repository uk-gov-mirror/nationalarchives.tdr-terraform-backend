locals {
  common_tags = map(
    "Owner", "TDR Backend",
    "Terraform", true
  )
}

provider "aws" {
  region = "eu-west-2"
}

module "terraform_state" {
  source = "./modules/state"

  common_tags = local.common_tags
}

module "terraform_state_lock" {
  source = "./modules/state-lock"

  common_tags = local.common_tags
}

module "terraform_permissions" {
  source = "./modules/permissions"

  common_tags = local.common_tags
}

module "jenkins_policies" {
  source = "./modules/jenkins"
  common_tags = local.common_tags
}