resource "aws_iam_role" "terraform_role" {
  name        = "TDRTerraformRole${title(var.tdr_environment)}"
  description = "Role to allow Terraform to create resources for the ${title(var.tdr_environment)} environment"
  assume_role_policy = templatefile(
  "./modules/grafana/templates/github_assume_role.json.tpl", { account_id = var.tdr_mgmt_account_number })

  tags = merge(
    var.common_tags,
    tomap(
      { "Name" = "${title(var.tdr_environment)} Terraform Role" }
    )
  )
}

resource "aws_iam_policy" "terraform_state_access_policy" {
  policy = templatefile(
    "./modules/grafana/templates/terraform_state_policy.json.tpl",
    {
      account_id          = var.tdr_mgmt_account_number
      state_bucket_arn    = var.terraform_grafana_state_bucket
      state_dynamo_db_arn = var.terraform_grafana_state_lock
    }
  )
  name = "TDRGrafanaTerraformStateAccess${title(var.tdr_environment)}"
}

resource "aws_iam_policy" "base_terraform_policy" {
  policy = templatefile(
    "./modules/grafana/templates/base_terraform_policy.json.tpl",
    {
      account_id  = var.tdr_mgmt_account_number
      environment = "mgmt"
    }
  )
  name = "TDRGrafanaTerraformBase${title(var.tdr_environment)}"
}

resource "aws_iam_policy" "shared_terraform_policy_1" {
  policy = templatefile(
    "./modules/environment-roles/templates/shared_terraform_policy_1.json.tpl",
    {
      environment = title(var.tdr_environment),
      account_id  = var.tdr_mgmt_account_number,
      sub_domain  = var.sub_domain
    }
  )
  name = "TDRSharedTerraform1${title(var.tdr_environment)}"
}

resource "aws_iam_policy" "shared_iam_terraform_policy" {
  policy = templatefile(
    "./modules/environment-roles/templates/shared_iam_terraform_policy.json.tpl",
    {
      environment = var.tdr_environment,
      account_id  = var.tdr_mgmt_account_number,
      sub_domain  = var.sub_domain
    }
  )
  name = "TDRSharedIamTerraform${title(var.tdr_environment)}"
}

resource "aws_iam_role_policy_attachment" "terraform_state_access_policy_attachment" {
  policy_arn = aws_iam_policy.terraform_state_access_policy.arn
  role       = aws_iam_role.terraform_role.name
}

resource "aws_iam_role_policy_attachment" "base_terraform_policy_attachment" {
  policy_arn = aws_iam_policy.base_terraform_policy.arn
  role       = aws_iam_role.terraform_role.name
}

resource "aws_iam_role_policy_attachment" "shared_policy_attachment_1" {
  policy_arn = aws_iam_policy.shared_terraform_policy_1.arn
  role       = aws_iam_role.terraform_role.name
}

resource "aws_iam_role_policy_attachment" "shared_iam_policy_attachment" {
  policy_arn = aws_iam_policy.shared_iam_terraform_policy.arn
  role       = aws_iam_role.terraform_role.name
}
