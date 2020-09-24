resource "aws_iam_role" "terraform_role" {
  name        = "TDRTerraformRole${title(var.tdr_environment)}"
  description = "Role to allow Terraform to create resources for the ${title(var.tdr_environment)} environment"
  assume_role_policy = templatefile(
    "./modules/environment-roles/templates/terraform_assume_role_policy.json.tpl",
    {
      account_id = var.tdr_mgmt_account_number
    }
  )

  tags = merge(
    var.common_tags,
    map(
      "Name", "${title(var.tdr_environment)} Terraform Role",
    )
  )
}

resource "aws_iam_policy" "shared_terraform_policy_1" {
  policy = templatefile(
    "./modules/environment-roles/templates/shared_terraform_policy_1.json.tpl",
    {
      environment = title(var.tdr_environment),
      account_id  = var.tdr_mgmt_account_number
    }
  )
  name = "TDRSharedTerraform1${title(var.tdr_environment)}"
}

resource "aws_iam_policy" "shared_terraform_policy_2" {
  policy = templatefile(
    "./modules/environment-roles/templates/shared_terraform_policy_2.json.tpl",
    {
      environment = title(var.tdr_environment),
      account_id  = var.tdr_mgmt_account_number,
      sub_domain  = var.sub_domain
    }
  )
  name = "TDRSharedTerraform2${title(var.tdr_environment)}"
}

resource "aws_iam_policy" "shared_terraform_policy_3" {
  policy = templatefile(
    "./modules/environment-roles/templates/shared_terraform_policy_3.json.tpl",
    {
      environment = title(var.tdr_environment),
      account_id  = var.tdr_mgmt_account_number,
      sub_domain  = var.sub_domain
    }
  )
  name = "TDRSharedTerraform3${title(var.tdr_environment)}"
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
