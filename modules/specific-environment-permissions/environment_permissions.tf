locals {
  env_title_case = title(var.tdr_environment)
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "ecs_assume_role" {
  version = "2012-10-17"

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

//IAM Policies: TDR Terraform Backend Permissions

data "aws_iam_policy_document" "write_terraform_state_bucket" {
  version = "2012-10-17"

  statement {
    effect  = "Allow"
    actions = ["s3:GetObject", "s3:PutObject"]
    resources = [
      "${var.terraform_state_bucket}/env:/${var.tdr_environment}/*",
      "${var.terraform_scripts_state_bucket}/env:/${var.tdr_environment}/*",
      "${var.terraform_backend_state_bucket}/*"
    ]
  }
}

resource "aws_iam_policy" "access_terraform_state" {
  name        = "TDR${local.env_title_case}AccessTerraformState"
  description = "Policy to allow read/write access to ${local.env_title_case} TDR environment state"
  policy      = data.aws_iam_policy_document.write_terraform_state_bucket.json
}

//IAM Roles: Terraform Assume Roles

data "aws_iam_policy_document" "terraform_assume_role" {
  version = "2012-10-17"

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    resources = [
      "arn:aws:iam::${var.tdr_account_number}:role/TDRTerraformRole${local.env_title_case}",
      "arn:aws:iam::${var.tdr_account_number}:role/TDRScriptsTerraformRole${local.env_title_case}"
    ]
  }
}

resource "aws_iam_policy" "terraform_ecs_policy" {
  name   = "TDRTerraformPolicy${local.env_title_case}"
  policy = data.aws_iam_policy_document.terraform_assume_role.json
}
