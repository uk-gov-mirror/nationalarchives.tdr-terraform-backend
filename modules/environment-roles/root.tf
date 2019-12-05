locals {
  environment = lookup(var.workspace_to_environment_map, terraform.workspace, "ci")
  common_tags = map(
    "Owner", "TDR",
    "Terraform", true
  )
}

provider "aws" {
  region  = "eu-west-2"
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

data "template_file" "s3_terraform_policy" {
  template = file("./templates/s3_terraform_policy.json.tpl")
  vars     = {}
}

resource "aws_iam_policy" "s3_terraform" {
  name        = "s3-terraform-policy"
  description = "Policy to give permission to Terraform s3 buckets"
  policy      = data.template_file.s3_terraform_policy.rendered
}
