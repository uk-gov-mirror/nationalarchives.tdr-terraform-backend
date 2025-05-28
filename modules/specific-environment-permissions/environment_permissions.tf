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

//IAM Roles: Custodian Assume Roles
data "aws_iam_policy_document" "custodian_assume_role" {
  version = "2012-10-17"

  statement {
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = ["arn:aws:iam::${var.tdr_account_number}:role/TDRCustodianDeployRole${local.env_title_case}"]
  }
}

resource "aws_iam_policy" "custodian_ecs_policy" {
  name   = "TDRCustodianPolicy${local.env_title_case}"
  policy = data.aws_iam_policy_document.custodian_assume_role.json
}

resource "aws_iam_policy" "custodian_ecr_policy" {
  name   = "TDRCustodianECRPolicy${local.env_title_case}"
  policy = templatefile("${path.module}/templates/custodian_ecr_scan_policy.json.tpl", { account_id = var.tdr_mgmt_account_number })
}

resource "aws_iam_role" "custodian_assume_role" {
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json
  name               = "TDRCustodianAssumeRole${local.env_title_case}"

  tags = merge(
    var.common_tags,
    tomap(
      { "Name" = "TDR Custodian Assume Role ${local.env_title_case}" }
    )
  )
}

resource "aws_iam_role_policy_attachment" "custodian_role_attachment" {
  role       = aws_iam_role.custodian_assume_role.name
  policy_arn = aws_iam_policy.custodian_ecs_policy.arn
}

resource "aws_iam_role_policy_attachment" "custodian_get_parameters" {
  role       = aws_iam_role.custodian_assume_role.name
  policy_arn = var.custodian_get_parameters_arn
}

resource "aws_iam_role_policy_attachment" "custodian_ecr_scan" {
  role       = aws_iam_role.custodian_assume_role.name
  policy_arn = aws_iam_policy.custodian_ecr_policy.arn
}
