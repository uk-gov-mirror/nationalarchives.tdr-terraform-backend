locals {
  environment         = lookup(var.workspace_to_environment_map, terraform.workspace, "intg")
  //environment_account = lookup(var.workspace_environment_account_map, terraform.workspace, "ci" )
  environment_profile = lookup(var.workspace_aws_profile_map, terraform.workspace, "intg")
  common_tags = map(
    "Owner", "TDR",
    "Terraform", true
  )
}

data "aws_caller_identity" "current" {}

provider "aws" {
  region  = "eu-west-2"
  profile = local.environment_profile
}

data "template_file" "terraform_assume_role_policy" {
  template = file("./templates/terraform_assume_role_policy.json.tpl")
  vars     = {}
}

resource "aws_iam_role" "terraform_role" {
  name               = "${local.environment}-terraform-role"
  description        = "Role to allow Terraform to create resources for the ${local.environment} environment"
  assume_role_policy = data.template_file.terraform_assume_role_policy.rendered

  tags = merge(
    local.common_tags,
      map(
        "Name", "${local.environment} Terraform Role",
      )
    )
}

resource "aws_iam_role_policy_attachment" "s3_policy_attachment" {
  role       = aws_iam_role.terraform_role.name
  policy_arn = aws_iam_policy.s3_terraform.arn
}

resource "aws_iam_role_policy_attachment" "keycloak_policy_attachment" {
  role       = aws_iam_role.terraform_role.name
  policy_arn = aws_iam_policy.keycloak_terraform.arn
}

data "template_file" "s3_terraform_policy" {
  template = file("./templates/s3_terraform_policy.json.tpl")
  vars     = {}
}

data "template_file" "keycloak_terraform_policy" {
  template = file("./templates/keycloak_terraform_policy.json.tpl")
  vars = {
    account_id = data.aws_caller_identity.current.account_id
    environment = local.environment
  }
}

resource "aws_iam_policy" "keycloak_terraform" {
  policy = data.template_file.keycloak_terraform_policy.rendered
  name = "keycloak-terraform-${local.environment}"
}

resource "aws_iam_policy" "s3_terraform" {
  name        = "s3-terraform-policy-${local.environment}"
  description = "Policy to give permission to Terraform s3 buckets"
  policy      = data.template_file.s3_terraform_policy.rendered
}
