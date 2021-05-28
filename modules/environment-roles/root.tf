data "aws_caller_identity" "current" {}

resource "aws_iam_role" "terraform_scripts_role" {
  name               = "TDRScriptsTerraformRole${title(var.tdr_environment)}"
  description        = "Role to allow terraform to run temporary scripts in the tdr-scripts repository"
  assume_role_policy = templatefile("./modules/environment-roles/templates/terraform_assume_role_policy.json.tpl", { account_id = var.tdr_mgmt_account_number })
}

resource "aws_iam_policy" "terraform_scripts_policy" {
  name   = "TDRScriptsTerraformPolicy${title(var.tdr_environment)}"
  policy = templatefile("${path.module}/templates/terraform_scripts_policy.json.tpl", { account_id = data.aws_caller_identity.current.account_id, title_environment = title(var.tdr_environment), environment = var.tdr_environment })
}

resource "aws_iam_role" "terraform_role" {
  name               = "TDRTerraformRole${title(var.tdr_environment)}"
  description        = "Role to allow Terraform to create resources for the ${title(var.tdr_environment)} environment"
  assume_role_policy = templatefile("./modules/environment-roles/templates/terraform_assume_role_policy.json.tpl", { account_id = var.tdr_mgmt_account_number })

  tags = merge(
    var.common_tags,
    map(
      "Name", "${title(var.tdr_environment)} Terraform Role",
    )
  )
}

resource "aws_iam_role_policy_attachment" "terraform_scripts_policy_attachment" {
  policy_arn = aws_iam_policy.terraform_scripts_policy.arn
  role       = aws_iam_role.terraform_scripts_role.name
}

resource "aws_iam_role_policy_attachment" "shared_policy_attachment_1" {
  policy_arn = aws_iam_policy.shared_terraform_policy_1.arn
  role       = aws_iam_role.terraform_role.name
}

resource "aws_iam_role_policy_attachment" "shared_policy_attachment_2" {
  policy_arn = aws_iam_policy.shared_terraform_policy_2.arn
  role       = aws_iam_role.terraform_role.name
}

resource "aws_iam_role_policy_attachment" "shared_policy_attachment_3" {
  policy_arn = aws_iam_policy.shared_terraform_policy_3.arn
  role       = aws_iam_role.terraform_role.name
}

resource "aws_iam_role_policy_attachment" "shared_policy_attachment_4" {
  policy_arn = aws_iam_policy.shared_terraform_policy_4.arn
  role       = aws_iam_role.terraform_role.name
}

resource "aws_iam_role_policy_attachment" "keycloak_policy_attachment" {
  role       = aws_iam_role.terraform_role.name
  policy_arn = aws_iam_policy.keycloak_terraform_iam.arn
}

resource "aws_iam_role_policy_attachment" "keycloak_ssm_policy_attachment" {
  role       = aws_iam_role.terraform_role.name
  policy_arn = aws_iam_policy.keycloak_terraform_ssm_parameters_iam.arn
}

resource "aws_iam_role_policy_attachment" "frontend_policy_attachment" {
  role       = aws_iam_role.terraform_role.name
  policy_arn = aws_iam_policy.frontend_terraform_iam.arn
}

resource "aws_iam_role_policy_attachment" "consignment_api_attachment" {
  role       = aws_iam_role.terraform_role.name
  policy_arn = aws_iam_policy.consignment_api_terraform_iam.arn
}

resource "aws_iam_role_policy_attachment" "consignment_api_ssm_policy_attachment" {
  role       = aws_iam_role.terraform_role.name
  policy_arn = aws_iam_policy.consignment_api_terraform_ssm_parameters_iam.arn
}

resource "aws_iam_policy" "shared_terraform_policy_1" {
  policy = templatefile("${path.module}/templates/shared_terraform_policy_1.json.tpl", { environment = title(var.tdr_environment), account_id = data.aws_caller_identity.current.account_id })
  name   = "TDRSharedTerraform1${title(var.tdr_environment)}"
}

resource "aws_iam_policy" "shared_terraform_policy_2" {
  policy = templatefile("${path.module}/templates/shared_terraform_policy_2.json.tpl", { environment = title(var.tdr_environment), account_id = data.aws_caller_identity.current.account_id, sub_domain = var.sub_domain })
  name   = "TDRSharedTerraform2${title(var.tdr_environment)}"
}

resource "aws_iam_policy" "shared_terraform_policy_3" {
  policy = templatefile("${path.module}/templates/shared_terraform_policy_3.json.tpl", { environment = title(var.tdr_environment), account_id = data.aws_caller_identity.current.account_id, sub_domain = var.sub_domain })
  name   = "TDRSharedTerraform3${title(var.tdr_environment)}"
}

resource "aws_iam_policy" "shared_terraform_policy_4" {
  policy = templatefile("${path.module}/templates/shared_terraform_policy_4.json.tpl", { environment = title(var.tdr_environment), account_id = data.aws_caller_identity.current.account_id, sub_domain = var.sub_domain })
  name   = "TDRSharedTerraform4${title(var.tdr_environment)}"
}

resource "aws_iam_policy" "keycloak_terraform_iam" {
  policy = templatefile("./modules/environment-roles/templates/app_base_terraform_policy.json.tpl", { account_id = data.aws_caller_identity.current.account_id, environment = var.tdr_environment, app_name = "keycloak" })
  name   = "TDRKeycloakTerraform${title(var.tdr_environment)}"
}

resource "aws_iam_policy" "keycloak_terraform_ssm_parameters_iam" {
  policy = templatefile("./modules/environment-roles/templates/app_base_terraform_ssm_parameters_policy.json.tpl", { account_id = data.aws_caller_identity.current.account_id, environment = var.tdr_environment, app_name = "keycloak" })
  name   = "TDRKeycloakTerraformSSM${title(var.tdr_environment)}"
}

resource "aws_iam_policy" "consignment_api_terraform_iam" {
  policy = templatefile("./modules/environment-roles/templates/app_base_terraform_policy.json.tpl", { account_id = data.aws_caller_identity.current.account_id, environment = var.tdr_environment, app_name = "consignmentapi" })
  name   = "TDRConsignmentApiTerraform${title(var.tdr_environment)}"
}

resource "aws_iam_policy" "consignment_api_terraform_ssm_parameters_iam" {
  policy = templatefile("./modules/environment-roles/templates/app_base_terraform_ssm_parameters_policy.json.tpl", { account_id = data.aws_caller_identity.current.account_id, environment = var.tdr_environment, app_name = "consignmentapi" })
  name   = "TDRConsignmentApiTerraformSSM${title(var.tdr_environment)}"
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
      "ssm:DescribeParameters",
      "ssm:GetParameter",
      "ssm:GetParameterByPath",
      "ssm:GetParameterHistory",
      "ssm:GetParameters",
      "ssm:ListTagsForResource",
      "ssm:PutParameter"
    ]
    resources = [
      "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/${var.tdr_environment}/frontend/play_secret",
      "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/${var.tdr_environment}/frontend/redis/host",
      "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/${var.tdr_environment}/frontend/auth/thumbprint"
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
  assume_role_policy = templatefile("./modules/environment-roles/templates/terraform_assume_role_policy.json.tpl", { account_id = var.tdr_mgmt_account_number })
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
  assume_role_policy = templatefile("./modules/environment-roles/templates/terraform_assume_role_policy.json.tpl", { account_id = var.tdr_mgmt_account_number })
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
      "s3:GetObject",
      "lambda:InvokeFunction",
      "lambda:UpdateFunctionCode",
      "lambda:PublishVersion",
      "lambda:UpdateEventSourceMapping",
      "ecs:RunTask",
      "iam:PassRole"
    ]
    resources = [
      "arn:aws:lambda:eu-west-2:${data.aws_caller_identity.current.account_id}:function:tdr-database-migrations-${var.tdr_environment}",
      "arn:aws:lambda:eu-west-2:${data.aws_caller_identity.current.account_id}:function:tdr-api-update-${var.tdr_environment}",
      "arn:aws:lambda:eu-west-2:${data.aws_caller_identity.current.account_id}:function:tdr-checksum-${var.tdr_environment}",
      "arn:aws:lambda:eu-west-2:${data.aws_caller_identity.current.account_id}:function:tdr-download-files-${var.tdr_environment}",
      "arn:aws:lambda:eu-west-2:${data.aws_caller_identity.current.account_id}:function:tdr-file-format-${var.tdr_environment}",
      "arn:aws:lambda:eu-west-2:${data.aws_caller_identity.current.account_id}:function:tdr-yara-av-${var.tdr_environment}",
      "arn:aws:lambda:eu-west-2:${data.aws_caller_identity.current.account_id}:function:tdr-export-api-authoriser-${var.tdr_environment}",
      "arn:aws:lambda:eu-west-2:${data.aws_caller_identity.current.account_id}:function:tdr-create-db-users-${var.tdr_environment}",
      "arn:aws:lambda:eu-west-2:${data.aws_caller_identity.current.account_id}:function:tdr-create-keycloak-db-user-${var.tdr_environment}",
      "arn:aws:lambda:eu-west-2:${data.aws_caller_identity.current.account_id}:function:tdr-notifications-${var.tdr_environment}",
      "arn:aws:s3:::tdr-backend-code-mgmt/*",
      "arn:aws:lambda:eu-west-2:${data.aws_caller_identity.current.account_id}:event-source-mapping:*",
      "arn:aws:ecs:eu-west-2:${data.aws_caller_identity.current.account_id}:task-definition/file-format-build-${var.tdr_environment}",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/file_format_ecs_execution_role_${var.tdr_environment}",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/TDRFileFormatECSExecutionRole${title(var.tdr_environment)}",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/TDRFileFormatEcsTaskRole${title(var.tdr_environment)}"

    ]
  }
  statement {
    actions = [
      "lambda:ListEventSourceMappings",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSubnets"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role" "tdr_jenkins_read_params_role" {
  name               = "TDRJenkinsReadParamsRole${title(var.tdr_environment)}"
  assume_role_policy = templatefile("./modules/environment-roles/templates/terraform_assume_role_policy.json.tpl", { account_id = var.tdr_mgmt_account_number })

  tags = merge(
    var.common_tags,
    map(
      "Name", "${title(var.tdr_environment)} Read Parameters role",
    )
  )
}

resource aws_iam_role_policy_attachment "tdr_jenkins_read_params_role_attach" {
  policy_arn = aws_iam_policy.tdr_jenkins_read_params_policy.arn
  role       = aws_iam_role.tdr_jenkins_read_params_role.name
}

resource "aws_iam_policy" "tdr_jenkins_read_params_policy" {
  name   = "TDRJenkinsReadParams${title(var.tdr_environment)}"
  policy = templatefile("${path.module}/templates/tdr_jenkins_read_params.json.tpl", { environment = var.tdr_environment, account_id = data.aws_caller_identity.current.account_id })
}

resource "aws_iam_role" "custodian_deploy_role" {
  name               = "TDRCustodianDeployRole${title(var.tdr_environment)}"
  description        = "Role to deploy Cloud Custodian to the ${title(var.tdr_environment)} environment"
  assume_role_policy = templatefile("./modules/environment-roles/templates/custodian_assume_role_policy.json.tpl", { account_id = var.tdr_mgmt_account_number })

  tags = merge(
    var.common_tags,
    map(
      "Name", "${title(var.tdr_environment)} Custodian Role",
    )
  )
}

resource "aws_iam_policy" "custodian_deploy_policy" {
  policy = templatefile("${path.module}/templates/custodian_policy.json.tpl", { environment = title(var.tdr_environment), account_id = data.aws_caller_identity.current.account_id })
  name   = "TDRCustodianDeployPolicy${title(var.tdr_environment)}"
}

resource aws_iam_role_policy_attachment "custodian_deploy_policy_attach" {
  policy_arn = aws_iam_policy.custodian_deploy_policy.arn
  role       = aws_iam_role.custodian_deploy_role.name
}

resource "aws_iam_role" "grafana_monitoring_iam_role" {
  name               = "TDRGrafanaMonitoringRole${title(var.tdr_environment)}"
  description        = "Role to permit Grafana to read Cloudwatch metrics and basic data like EC2 tags and regions."
  assume_role_policy = templatefile("./modules/environment-roles/templates/grafana_assume_role_policy.json.tpl", { account_id = var.tdr_mgmt_account_number })

  tags = merge(
    var.common_tags,
    map(
      "Name", "${title(var.tdr_environment)} Grafana Monitoring Role",
    )
  )
}

resource "aws_iam_policy" "grafana_monitoring_policy" {
  policy = templatefile("${path.module}/templates/grafana_monitoring_policy.json.tpl", {})
  name   = "TDRGrafanaMonitoringPolicy${title(var.tdr_environment)}"
}

resource aws_iam_role_policy_attachment "grafana_monitoring_policy_attach" {
  policy_arn = aws_iam_policy.grafana_monitoring_policy.arn
  role       = aws_iam_role.grafana_monitoring_iam_role.name
}

resource "aws_iam_role" "jenkins_export_s3_role" {
  count              = var.tdr_environment == "prod" ? 0 : 1
  name               = "TDRJenkinsS3ExportRole${title(var.tdr_environment)}"
  assume_role_policy = templatefile("${path.module}/templates/terraform_assume_role_policy.json.tpl", { account_id = var.tdr_mgmt_account_number })
  tags = merge(
    var.common_tags,
    map(
      "Name", "TDR S3 Export Access Role for ECS ${var.tdr_environment}",
    )
  )
}

resource "aws_iam_policy" "jenkins_export_s3_policy" {
  count  = var.tdr_environment == "prod" ? 0 : 1
  name   = "TDRJenkinsS3ExportPolicy${title(var.tdr_environment)}"
  policy = templatefile("${path.module}/templates/jenkins_export_s3_policy.json.tpl", { environment = var.tdr_environment })
}

resource "aws_iam_role_policy_attachment" "jenkins_export_s3_attach" {
  count      = var.tdr_environment == "prod" ? 0 : 1
  policy_arn = aws_iam_policy.jenkins_export_s3_policy[count.index].arn
  role       = aws_iam_role.jenkins_export_s3_role[count.index].id
}
