data "aws_caller_identity" "current" {}

module "global_parameters" {
  source = "../../tdr-configurations/terraform"
}

resource "aws_iam_role" "terraform_restore_db_role" {
  name               = "TDRRestoreDbTerraformRole${title(var.tdr_environment)}"
  description        = "Role to allow terraform to create a new rds cluster from a snapshot"
  assume_role_policy = templatefile("./modules/environment-roles/templates/terraform_assume_role_policy.json.tpl", { account_id = var.tdr_mgmt_account_number, external_id = var.restore_db_external_id })
}

resource "aws_iam_policy" "terraform_restore_db_policy" {
  name   = "TDRRestoreDbTerraformPolicy${title(var.tdr_environment)}"
  policy = templatefile("${path.module}/templates/terraform_restore_db_policy.json.tpl", { account_id = data.aws_caller_identity.current.account_id, title_environment = title(var.tdr_environment), environment = var.tdr_environment })
}

resource "aws_iam_role_policy_attachment" "terraform_restore_db_attach" {
  policy_arn = aws_iam_policy.terraform_restore_db_policy.arn
  role       = aws_iam_role.terraform_restore_db_role.id
}

resource "aws_iam_role" "terraform_scripts_role" {
  name               = "TDRScriptsTerraformRole${title(var.tdr_environment)}"
  description        = "Role to allow terraform to run temporary scripts in the tdr-scripts repository"
  assume_role_policy = templatefile("./modules/environment-roles/templates/terraform_assume_role_policy.json.tpl", { account_id = var.tdr_mgmt_account_number, external_id = var.terraform_scripts_external_id })
}

resource "aws_iam_policy" "terraform_scripts_policy" {
  name   = "TDRScriptsTerraformPolicy${title(var.tdr_environment)}"
  policy = templatefile("${path.module}/templates/terraform_scripts_policy.json.tpl", { account_id = data.aws_caller_identity.current.account_id, title_environment = title(var.tdr_environment), environment = var.tdr_environment })
}

resource "aws_iam_role" "terraform_role" {
  name               = "TDRTerraformRole${title(var.tdr_environment)}"
  description        = "Role to allow Terraform to create resources for the ${title(var.tdr_environment)} environment"
  assume_role_policy = templatefile("./modules/environment-roles/templates/terraform_assume_role_policy.json.tpl", { account_id = var.tdr_mgmt_account_number, external_id = var.terraform_external_id })
  tags = merge(
    var.common_tags,
    tomap(
      { "Name" = "${title(var.tdr_environment)} Terraform Role" }
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

resource "aws_iam_role_policy_attachment" "shared_iam_policy_attachment" {
  policy_arn = aws_iam_policy.shared_iam_terraform_policy.arn
  role       = aws_iam_role.terraform_role.name
}

resource "aws_iam_role_policy_attachment" "shared_iam_policy_attachment_1" {
  policy_arn = aws_iam_policy.shared_iam_terraform_policy_1.arn
  role       = aws_iam_role.terraform_role.name
}

resource "aws_iam_policy" "consignment_api_connection_secret_creation_policy" {
  name        = "TDRConsignmentApiSecretCreationPolicy${title(var.tdr_environment)}"
  description = "Policy to enable the creation of secrets from the consignment API connection"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:CreateSecret",
          "secretsmanager:PutSecretValue",
          "secretsmanager:GetSecretValue"
        ]
        Resource = "arn:aws:secretsmanager:*:*:secret:events!connection/TDRConsignmentAPIConnection${title(var.tdr_environment)}/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "amazon_eventbridge_policy_attachment" {
  policy_arn = aws_iam_policy.consignment_api_connection_secret_creation_policy.arn
  role       = aws_iam_role.terraform_role.name
}

resource "aws_iam_policy" "shared_terraform_policy_1" {
  policy = templatefile("${path.module}/templates/shared_terraform_policy_1.json.tpl", {})
  name   = "TDRSharedTerraform1${title(var.tdr_environment)}"
}

resource "aws_iam_policy" "shared_iam_terraform_policy" {
  policy = templatefile("${path.module}/templates/shared_iam_terraform_policy.json.tpl", { environment = var.tdr_environment, account_id = data.aws_caller_identity.current.account_id })
  name   = "TDRSharedIamTerraform${title(var.tdr_environment)}"
}

resource "aws_iam_policy" "shared_iam_terraform_policy_1" {
  policy = templatefile("${path.module}/templates/shared_iam_terraform_policy_1.json.tpl", { environment = var.tdr_environment, account_id = data.aws_caller_identity.current.account_id })
  name   = "TDRSharedIamTerraform1${title(var.tdr_environment)}"
}

data "aws_iam_policy_document" "frontend_storage_override" {
  statement {
    sid    = "storage"
    effect = "Allow"
    actions = [
      "elasticache:CreateCacheCluster",
      "elasticache:CreateCacheSubnetGroup",
      "elasticache:CreateReplicationGroup",
      "elasticache:DeleteCacheCluster",
      "elasticache:DeleteCacheSubnetGroup",
      "elasticache:DeleteReplicationGroup",
      "elasticache:DescribeCacheClusters",
      "elasticache:DescribeCacheSubnetGroups",
      "elasticache:DescribeReplicationGroups",
      "elasticache:ListTagsForResource",
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

resource "aws_iam_role" "custodian_deploy_role" {
  name               = "TDRCustodianDeployRole${title(var.tdr_environment)}"
  description        = "Role to deploy Cloud Custodian to the ${title(var.tdr_environment)} environment"
  assume_role_policy = templatefile("./modules/environment-roles/templates/custodian_assume_role_policy.json.tpl", { account_id = var.tdr_mgmt_account_number })

  tags = merge(
    var.common_tags,
    tomap(
      { "Name" = "${title(var.tdr_environment)} Custodian Role" }
    )
  )
}

resource "aws_iam_role" "github_actions_custodian_deploy_role" {
  name        = "TDRGithubActionsCustodianDeployRole${title(var.tdr_environment)}"
  description = "Role to deploy Cloud Custodian to the ${title(var.tdr_environment)} environment from GitHub actions"
  assume_role_policy = templatefile("./modules/environment-roles/templates/github_assume_role.json.tpl", {
    account_id = data.aws_caller_identity.current.account_id,
    repo_names = jsonencode(concat(module.global_parameters.github_tdr_active_repositories, [var.github_tna_custodian_repository, var.github_da_reference_generator_repository]))
  })

  tags = merge(
    var.common_tags,
    tomap(
      { "Name" = "${title(var.tdr_environment)} Custodian Role" }
    )
  )
}

resource "aws_iam_role_policy_attachment" "github_actions_custodian_deploy_policy_attach" {
  policy_arn = aws_iam_policy.custodian_deploy_policy.arn
  role       = aws_iam_role.github_actions_custodian_deploy_role.name
}

resource "aws_iam_policy" "custodian_deploy_policy" {
  policy = templatefile("${path.module}/templates/custodian_policy.json.tpl", { environment = var.tdr_environment, account_id = data.aws_caller_identity.current.account_id })
  name   = "TDRCustodianDeployPolicy${title(var.tdr_environment)}"
}

resource "aws_iam_role_policy_attachment" "custodian_deploy_policy_attach" {
  policy_arn = aws_iam_policy.custodian_deploy_policy.arn
  role       = aws_iam_role.custodian_deploy_role.name
}

resource "aws_iam_role" "grafana_monitoring_iam_role" {
  name               = "TDRGrafanaMonitoringRole${title(var.tdr_environment)}"
  description        = "Role to permit Grafana to read Cloudwatch metrics and basic data like EC2 tags and regions."
  assume_role_policy = templatefile("./modules/environment-roles/templates/grafana_assume_role_policy.json.tpl", { account_id = var.tdr_mgmt_account_number, external_id = var.grafana_management_external_id })

  tags = merge(
    var.common_tags,
    tomap(
      { "Name" = "${title(var.tdr_environment)} Grafana Monitoring Role" }
    )
  )
}

resource "aws_iam_policy" "grafana_monitoring_policy" {
  policy = templatefile("${path.module}/templates/grafana_monitoring_policy.json.tpl", {})
  name   = "TDRGrafanaMonitoringPolicy${title(var.tdr_environment)}"
}

resource "aws_iam_role_policy_attachment" "grafana_monitoring_policy_attach" {
  policy_arn = aws_iam_policy.grafana_monitoring_policy.arn
  role       = aws_iam_role.grafana_monitoring_iam_role.name
}


resource "aws_iam_role" "github_actions_describe_ec2_role" {
  name = "TDRGithubActionsDescribeEC2Role${title(var.tdr_environment)}"
  assume_role_policy = templatefile("${path.module}/templates/github_assume_role.json.tpl", {
    account_id = data.aws_caller_identity.current.account_id,
    repo_names = jsonencode(concat(module.global_parameters.github_tdr_active_repositories, [var.github_tna_custodian_repository, var.github_da_reference_generator_repository]))
  })
}

resource "aws_iam_policy" "github_actions_describe_ec2_policy" {
  name   = "TDRGithubActionsDescribeEC2Policy${title(var.tdr_environment)}"
  policy = templatefile("${path.module}/templates/run_ec2_describe.json.tpl", {})
}

resource "aws_iam_role_policy_attachment" "github_actions_describe_ec2_attach" {
  policy_arn = aws_iam_policy.github_actions_describe_ec2_policy.arn
  role       = aws_iam_role.github_actions_describe_ec2_role.id
}

resource "aws_iam_role" "github_service_unavailable_deploy_role" {
  name = "TDRGithubActionsDeployServiceUnavailableRole${title(var.tdr_environment)}"
  assume_role_policy = templatefile("./modules/environment-roles/templates/github_assume_role.json.tpl", {
    account_id = data.aws_caller_identity.current.account_id,
    repo_names = jsonencode(concat(module.global_parameters.github_tdr_active_repositories, [var.github_tna_custodian_repository, var.github_da_reference_generator_repository]))
  })
}

resource "aws_iam_policy" "github_service_unavailable_deploy_policy" {
  name   = "TDRGithubActionsDeployServiceUnavailablePolicy${title(var.tdr_environment)}"
  policy = templatefile("${path.module}/templates/jenkins_service_unavailable_deploy_policy.json.tpl", {})
}

resource "aws_iam_role_policy_attachment" "github_service_unavailable_attach" {
  policy_arn = aws_iam_policy.github_service_unavailable_deploy_policy.arn
  role       = aws_iam_role.github_service_unavailable_deploy_role.id
}

resource "aws_iam_policy" "shared_reference_generator_policy" {
  name   = "TDRReferenceGeneratorTerraformPolicy${title(var.tdr_environment)}"
  policy = templatefile("${path.module}/templates/shared_reference_generator_policy.json.tpl", { account_id = data.aws_caller_identity.current.account_id, environment = var.tdr_environment })
}

resource "aws_iam_role_policy_attachment" "shared_reference_generator_attach" {
  policy_arn = aws_iam_policy.shared_reference_generator_policy.arn
  role       = aws_iam_role.terraform_role.id
}
