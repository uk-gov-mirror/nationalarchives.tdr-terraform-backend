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

resource "aws_iam_role_policy_attachment" "shared_policy_attachment" {
  policy_arn = aws_iam_policy.shared_terraform_policy.arn
  role = aws_iam_role.terraform_role.name
}

resource "aws_iam_role_policy_attachment" "keycloak_policy_attachment" {
  role       = aws_iam_role.terraform_role.name
  policy_arn = aws_iam_policy.keycloak_terraform_iam.arn
}

resource "aws_iam_role_policy_attachment" "frontend_policy_attachment" {
  role       = aws_iam_role.terraform_role.name
  policy_arn = aws_iam_policy.frontend_terraform_iam.arn
}

resource "aws_iam_role_policy_attachment" "consignment_api_attachment" {
  role = aws_iam_role.terraform_role.name
  policy_arn = aws_iam_policy.consignment_api_terraform_iam.arn
}

data "template_file" "keycloak_terraform_policy" {
  template = file("./modules/environment-roles/templates/app_base_terraform_policy.json.tpl")
  vars = {
    account_id  = data.aws_caller_identity.current.account_id
    environment = var.tdr_environment
    app_name    = "keycloak"
  }
}

resource "aws_iam_policy" "shared_terraform_policy" {
  policy = data.template_file.shared_terraform_policy_template.rendered
  name = "TDRSharedTerraform${title(var.tdr_environment)}"
}

data "template_file" "shared_terraform_policy_template" {
  template = file("${path.module}/templates/shared_terraform_policy.json.tpl")
  vars = {
    environment = title(var.tdr_environment)
    account_id = data.aws_caller_identity.current.account_id
  }
}

resource "aws_iam_policy" "keycloak_terraform_iam" {
  policy = data.template_file.keycloak_terraform_policy.rendered
  name   = "TDRKeycloakTerraform${title(var.tdr_environment)}"
}

data "template_file" "consignment_api_terraform_policy" {
  template = file("./modules/environment-roles/templates/app_base_terraform_policy.json.tpl")
  vars = {
    account_id  = data.aws_caller_identity.current.account_id
    environment = var.tdr_environment
    app_name    = "consignmentapi"
  }
}

resource "aws_iam_policy" "consignment_api_terraform_iam" {
  policy = data.template_file.consignment_api_terraform_policy.rendered
  name   = "TDRConsignmentApiTerraform${title(var.tdr_environment)}"
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
      "elasticache:DeleteReplicationGroup",
      "elasticache:DeleteCacheSubnetGroup"
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
      "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/${var.tdr_environment}/frontend/redis/host"
    ]
  }
}

data "aws_iam_policy_document" "frontend_terraform_iam" {
  source_json   = data.template_file.frontend_terraform_policy.rendered
  override_json = data.aws_iam_policy_document.frontend_storage_override.json
}

data "template_file" "frontend_terraform_policy" {
  template = file("./modules/environment-roles/templates/app_base_terraform_policy.json.tpl")
  vars = {
    account_id  = data.aws_caller_identity.current.account_id
    environment = var.tdr_environment
    app_name    = "frontend"
  }
}

resource "aws_iam_policy" "frontend_terraform_iam" {
  policy = data.aws_iam_policy_document.frontend_terraform_iam.json
  name   = "TDRFrontendTerraform${title(var.tdr_environment)}"

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
      "arn:aws:ecs:eu-west-2:${data.aws_caller_identity.current.account_id}:service/keycloak_${var.tdr_environment}/keycloak_service_${var.tdr_environment}",
      "arn:aws:ecs:eu-west-2:${data.aws_caller_identity.current.account_id}:service/consignmentapi_${var.tdr_environment}/consignmentapi_service_${var.tdr_environment}"
    ]
  }
}

resource "aws_iam_role" "tdr_jenkins_lambda_role" {
  name               = "TDRJenkinsLambdaRole${title(var.tdr_environment)}"
  assume_role_policy = data.template_file.terraform_assume_role_policy.rendered
}

resource "aws_iam_role_policy_attachment" "tdr_jenkins_lambda_role_attach" {
  policy_arn = aws_iam_policy.tdr_jenkins_lambda_policy.arn
  role       = aws_iam_role.tdr_jenkins_lambda_role.name
}

resource "aws_iam_policy" "tdr_jenkins_lambda_policy" {
  name   = "TDRJenkinsLambda${title(var.tdr_environment)}"
  policy = data.aws_iam_policy_document.tdr_jenkins_lambda.json
}

data "aws_iam_policy_document" "tdr_jenkins_lambda" {
  statement {
    actions = [
      "lambda:InvokeFunction",
      "lambda:UpdateFunctionCode"
    ]
    resources = [
      "arn:aws:lambda:eu-west-2:${data.aws_caller_identity.current.account_id}:function:tdr-database-migrations-${var.tdr_environment}",
    ]
  }
}