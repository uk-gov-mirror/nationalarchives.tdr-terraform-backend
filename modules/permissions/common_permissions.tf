//IAM Group: Deny All Access

resource "aws_iam_group" "tdr_deny_access" {
  name = "TDRDenyAccess"
}

resource "aws_iam_group_policy_attachment" "deny_all_access" {
  group      = aws_iam_group.tdr_deny_access.name
  policy_arn = "arn:aws:iam::aws:policy/AWSDenyAll"
}

data "aws_iam_policy_document" "read_terraform_state_bucket" {
  version = "2012-10-17"

  statement {
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [var.terraform_state_bucket, var.terraform_scripts_state_bucket, var.terraform_backend_state_bucket, var.terraform_github_state_bucket]
  }
}

resource "aws_iam_policy" "read_terraform_state" {
  name        = "TDRReadTerraformState"
  description = "Policy to allow access to TDR environments' states"
  policy      = data.aws_iam_policy_document.read_terraform_state_bucket.json
}

data "aws_iam_policy_document" "terraform_state_lock" {
  version = "2012-10-17"

  statement {
    effect    = "Allow"
    actions   = ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:DeleteItem"]
    resources = [var.terraform_state_lock, var.terraform_scripts_state_lock, var.terraform_github_state_lock]
  }

  statement {
    effect    = "Allow"
    actions   = ["s3:DeleteObject"]
    resources = ["${var.terraform_state_bucket}/*/*.tflock"]
  }
}

resource "aws_iam_policy" "terraform_state_lock_access" {
  name        = "TDRTerraformStateLockAccess"
  description = "Policy to allow access to DyanmoDb to obtain lock to amend Terraform state"
  policy      = data.aws_iam_policy_document.terraform_state_lock.json
}

data "aws_iam_policy_document" "terraform_describe_account" {
  version = "2012-10-17"

  statement {
    effect    = "Allow"
    actions   = ["ec2:DescribeAccountAttributes", "ec2:DescribeAvailabilityZones"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "terraform_describe_account" {
  name        = "TDRTerraformDescribeAccount"
  description = "Policy to allow terraform to describe the accounts"
  policy      = data.aws_iam_policy_document.terraform_describe_account.json
}

data "aws_caller_identity" "current" {}
