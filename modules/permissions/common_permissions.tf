data "aws_iam_policy_document" "read_terraform_state_bucket" {
  version = "2012-10-17"

  statement {
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [var.terraform_state_bucket]
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
    resources = [var.terraform_state_lock]
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
