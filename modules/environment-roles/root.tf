data "aws_caller_identity" "current" {}

data "template_file" "terraform_assume_role_policy" {
  template = file("./modules/environment-roles/templates/terraform_assume_role_policy.json.tpl")
  vars     = {}
}

resource "aws_iam_role" "terraform_role" {
  name               = "TDRTerraformRole${title(var.tdr_environment)}"
  description        = "Role to allow Terraform to create resources for the ${title(var.tdr_environment)} environment"
  assume_role_policy = data.template_file.terraform_assume_role_policy.rendered

  tags = merge(
    var.common_tags,
    map(
      "Name", "${title(var.tdr_environment)} Terraform Role",
    )
  )
}

resource "aws_iam_role_policy_attachment" "keycloak_policy_attachment_part_a" {
  role       = aws_iam_role.terraform_role.name
  policy_arn = aws_iam_policy.keycloak_terraform_iam_part_a.arn
}

resource "aws_iam_role_policy_attachment" "keycloak_policy_attachment_part_b" {
  role       = aws_iam_role.terraform_role.name
  policy_arn = aws_iam_policy.keycloak_terraform_iam_part_b.arn
}

resource "aws_iam_role_policy_attachment" "frontend_policy_attachment_part_a" {
  role       = aws_iam_role.terraform_role.name
  policy_arn = aws_iam_policy.frontend_terraform_iam_part_a.arn
}

resource "aws_iam_role_policy_attachment" "frontend_policy_attachment_part_b" {
  role       = aws_iam_role.terraform_role.name
  policy_arn = aws_iam_policy.frontend_terraform_iam_part_b.arn
}

data "template_file" "keycloak_terraform_policy_part_b" {
  template = file("./modules/environment-roles/templates/app_base_terraform_policy_part_b.json.tpl")
  vars = {
    account_id  = data.aws_caller_identity.current.account_id
    environment = var.tdr_environment
    app_name    = "keycloak"
  }
}

resource "aws_iam_policy" "keycloak_terraform_iam_part_b" {
  policy = data.template_file.keycloak_terraform_policy_part_b.rendered
  name   = "TDRKeycloakTerraform${title(var.tdr_environment)}-part-b"
}

data "template_file" "keycloak_terraform_policy_part_a" {
  template = file("./modules/environment-roles/templates/app_base_terraform_policy_part_a.json.tpl")
  vars = {
    account_id  = data.aws_caller_identity.current.account_id
    environment = var.tdr_environment
    app_name    = "keycloak"
  }
}

resource "aws_iam_policy" "keycloak_terraform_iam_part_a" {
  policy = data.template_file.keycloak_terraform_policy_part_a.rendered
  name   = "TDRKeycloakTerraform${title(var.tdr_environment)}-part-a"
}

data "template_file" "frontend_terraform_policy_part_b" {
  template = file("./modules/environment-roles/templates/app_base_terraform_policy_part_b.json.tpl")
  vars = {
    account_id  = data.aws_caller_identity.current.account_id
    environment = var.tdr_environment
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
      "elasticache:DescribeCacheClusters",
      "elasticache:ModifyCacheCluster",
      "elasticache:RebootCacheCluster",
      "elasticache:CreateCacheSubnetGroup",
      "elasticache:CreateReplicationGroup",
      "elasticache:DescribeCacheSubnetGroups",
      "elasticache:DescribeReplicationGroups",
      "elasticache:DeleteReplicationGroup"
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
      "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/${var.tdr_environment}/frontend/play_secret",
      "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/${var.tdr_environment}/frontend/redis/host",
      "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/${var.tdr_environment}/frontend/redis/password"
    ]
  }
}

data "aws_iam_policy_document" "frontend_terraform_iam_part_b" {
  source_json   = data.template_file.frontend_terraform_policy_part_b.rendered
  override_json = data.aws_iam_policy_document.frontend_storage_override.json
}

resource "aws_iam_policy" "frontend_terraform_iam_part_b" {
  policy = data.aws_iam_policy_document.frontend_terraform_iam_part_b.json
  name   = "TDRFrontendTerraform${title(var.tdr_environment)}-part-b"
}

data "template_file" "frontend_terraform_policy_part_a" {
  template = file("./modules/environment-roles/templates/app_base_terraform_policy_part_a.json.tpl")
  vars = {
    account_id  = data.aws_caller_identity.current.account_id
    environment = var.tdr_environment
    app_name    = "frontend"
  }
}

resource "aws_iam_policy" "frontend_terraform_iam_part_a" {
  policy = data.template_file.frontend_terraform_policy_part_a.rendered
  name   = "TDRFrontendTerraform${title(var.tdr_environment)}-part-a"
}

resource "aws_iam_role" "tdr_jenkins_ecs_update_role" {
  name               = "TDRJenkinsECSUpdateRole${title(var.tdr_environment)}"
  assume_role_policy = data.template_file.terraform_assume_role_policy.rendered
}

resource "aws_iam_role_policy_attachment" "tdr_jenkins_ecs_update_role_attach" {
  policy_arn = aws_iam_policy.tdr_jenkins_update_ecs_policy.arn
  role       = aws_iam_role.tdr_jenkins_ecs_update_role.name
}

resource "aws_iam_policy" "tdr_jenkins_update_ecs_policy" {
  name   = "TDRJenkinsUpdateECS${title(var.tdr_environment)}"
  policy = data.aws_iam_policy_document.tdr_jenkins_update_ecs_service.json
}

data "aws_iam_policy_document" "tdr_jenkins_update_ecs_service" {
  statement {
    actions = [
      "ecs:UpdateService"
    ]
    resources = [
      "arn:aws:ecs:eu-west-2:${data.aws_caller_identity.current.account_id}:service/frontend_${var.tdr_environment}/frontend_service_${var.tdr_environment}",
      "arn:aws:ecs:eu-west-2:${data.aws_caller_identity.current.account_id}:service/keycloak_${var.tdr_environment}/keycloak_service_${var.tdr_environment}"
    ]
  }
}
