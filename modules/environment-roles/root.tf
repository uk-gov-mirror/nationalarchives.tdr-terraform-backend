locals {
  environment         = lookup(var.workspace_to_environment_map, terraform.workspace, "intg")
  environment_profile = lookup(var.workspace_aws_profile_map, terraform.workspace, "intg")
  common_tags = map(
    "Owner", "TDR",
    "Terraform", true
  )
}

data "aws_caller_identity" "current" {}

terraform {
  backend "s3" {
    bucket         = "tdr-bootstrap-terraform-state"
    key            = "terraform.env.state"
    region         = "eu-west-2"
    encrypt        = true
    dynamodb_table = "tdr-bootstrap-terraform-state-lock"
  }
}

provider "aws" {
  region  = "eu-west-2"
  profile = local.environment_profile
}

data "template_file" "terraform_assume_role_policy" {
  template = file("./templates/terraform_assume_role_policy.json.tpl")
  vars     = {}
}

resource "aws_iam_role" "terraform_role" {
  name               = "TDRTerraformRole${title(local.environment)}"
  description        = "Role to allow Terraform to create resources for the ${local.environment} environment"
  assume_role_policy = data.template_file.terraform_assume_role_policy.rendered

  tags = merge(
    local.common_tags,
    map(
      "Name", "${local.environment} Terraform Role",
    )
  )
}

resource "aws_iam_role_policy_attachment" "keycloak_policy_attachment_a" {
  role       = aws_iam_role.terraform_role.name
  policy_arn = aws_iam_policy.keycloak_terraform_iam_a.arn
}

resource "aws_iam_role_policy_attachment" "keycloak_policy_attachment_b" {
  role       = aws_iam_role.terraform_role.name
  policy_arn = aws_iam_policy.keycloak_terraform_iam_b.arn
}

resource "aws_iam_role_policy_attachment" "frontend_policy_attachment_a" {
  role       = aws_iam_role.terraform_role.name
  policy_arn = aws_iam_policy.frontend_terraform_iam_a.arn
}

resource "aws_iam_role_policy_attachment" "frontend_policy_attachment_b" {
  role       = aws_iam_role.terraform_role.name
  policy_arn = aws_iam_policy.frontend_terraform_iam_b.arn
}

data "template_file" "keycloak_terraform_policy_b" {
  template = file("./templates/app_base_terraform_policy_b.json.tpl")
  vars = {
    account_id  = data.aws_caller_identity.current.account_id
    environment = local.environment
    app_name    = "keycloak"
  }
}

resource "aws_iam_policy" "keycloak_terraform_iam_b" {
  policy = data.template_file.keycloak_terraform_policy_b.rendered
  name   = "TDRKeycloakTerraform${title(local.environment)}-b"
}

data "template_file" "keycloak_terraform_policy_a" {
  template = file("./templates/app_base_terraform_policy_a.json.tpl")
  vars = {
    account_id  = data.aws_caller_identity.current.account_id
    environment = local.environment
    app_name    = "keycloak"
  }
}

resource "aws_iam_policy" "keycloak_terraform_iam_a" {
  policy = data.template_file.keycloak_terraform_policy_a.rendered
  name   = "TDRKeycloakTerraform${title(local.environment)}-a"
}

data "template_file" "frontend_terraform_policy_b" {
  template = file("./templates/app_base_terraform_policy_b.json.tpl")
  vars = {
    account_id  = data.aws_caller_identity.current.account_id
    environment = local.environment
    app_name    = "frontend"
  }
}

data "aws_iam_policy_document" "frontend_storage_override" {
  statement {
    sid    = "storage"
    effect = "Allow"
    actions = [
      "elasticache:CreateCacheCluster",
      "elasticache:DeleteCacheCluster",
      "elasticache:DescribeCacheCluster",
      "elasticache:DescribeCacheClusters",
      "elasticache:ModifyCacheCluster",
      "elasticache:RebootCacheCluster"
    ]
    resources = ["*"]
  }
  statement {
    sid    = "ssm"
    effect = "Allow"
    actions = [
      "ssm:AddTagsToResource",
      "ssm:DeleteParameter",
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:ListTagsForResource",
      "ssm:PutParameter"
    ]
    resources = [
      "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/${local.environment}/frontend/play_secret"
    ]
  }
}

data "aws_iam_policy_document" "frontend_terraform_iam_b" {
  source_json   = data.template_file.frontend_terraform_policy_b.rendered
  override_json = data.aws_iam_policy_document.frontend_storage_override.json
}

resource "aws_iam_policy" "frontend_terraform_iam_b" {
  policy = data.aws_iam_policy_document.frontend_terraform_iam_b.json
  name   = "TDRFrontendTerraform${title(local.environment)}-b"
}

data "template_file" "frontend_terraform_policy_a" {
  template = file("./templates/app_base_terraform_policy_a.json.tpl")
  vars = {
    account_id  = data.aws_caller_identity.current.account_id
    environment = local.environment
    app_name    = "frontend"
  }
}

resource "aws_iam_policy" "frontend_terraform_iam_a" {
  policy = data.template_file.frontend_terraform_policy_a.rendered
  name   = "TDRFrontendTerraform${title(local.environment)}-a"
}

resource "aws_iam_role" "tdr_jenkins_ecs_update_role" {
  name               = "TDRJenkinsECSUpdateRole${title(local.environment)}"
  assume_role_policy = data.template_file.terraform_assume_role_policy.rendered
}

resource "aws_iam_role_policy_attachment" "tdr_jenkins_ecs_update_role_attach" {
  policy_arn = aws_iam_policy.tdr_jenkins_update_ecs_policy.arn
  role       = aws_iam_role.tdr_jenkins_ecs_update_role.name
}

resource "aws_iam_policy" "tdr_jenkins_update_ecs_policy" {
  name   = "TDRJenkinsUpdateECS${title(local.environment)}"
  policy = data.aws_iam_policy_document.tdr_jenkins_update_ecs_service.json
}

data "aws_iam_policy_document" "tdr_jenkins_update_ecs_service" {
  statement {
    actions = [
      "ecs:UpdateService"
    ]
    resources = [
      "arn:aws:ecs:eu-west-2:${data.aws_caller_identity.current.account_id}:service/frontend_${local.environment}/frontend_service_${local.environment}"
    ]
  }
}
