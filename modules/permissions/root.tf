//Developers can only Terraform the intg environment
resource "aws_iam_group" "tdr_terraform_developers" {
  name = "tdr-terraform-developers"
}

//Administrators can Terraform all environments
resource "aws_iam_group" "tdr_terraform_administrators" {
  name = "tdr-terraform-administrators"
}

resource "aws_iam_group" "tdr_deny_access" {
  name = "tdr-deny-access"
}

resource "aws_iam_group_policy_attachment" "deny_all_access" {
  group      = aws_iam_group.tdr_deny_access.name
  policy_arn = "arn:aws:iam::aws:policy/AWSDenyAll"
}

resource "aws_iam_group_policy_attachment" "developers_terraform_assume_role_intg" {
  group      = aws_iam_group.tdr_terraform_developers.name
  policy_arn = aws_iam_policy.intg_terraform_assume_role.arn
}

resource "aws_iam_group_policy_attachment" "developers_access_terraform_state" {
  group      = aws_iam_group.tdr_terraform_developers.name
  policy_arn = aws_iam_policy.read_terraform_state.arn
}

resource "aws_iam_group_policy_attachment" "developers_change_terraform_state" {
  group      = aws_iam_group.tdr_terraform_developers.name
  policy_arn = aws_iam_policy.intg_access_terraform_state.arn
}

resource "aws_iam_group_policy_attachment" "developers_access_terraform_state_lock" {
  group      = aws_iam_group.tdr_terraform_developers.name
  policy_arn = aws_iam_policy.terraform_state_lock_access.arn
}

resource "aws_iam_group_policy_attachment" "developers_describe_accounts" {
  group      = aws_iam_group.tdr_terraform_developers.name
  policy_arn = aws_iam_policy.terraform_describe_account.arn
}

resource "aws_iam_group_policy_attachment" "administrators_describe_accounts" {
  group      = aws_iam_group.tdr_terraform_administrators.name
  policy_arn = aws_iam_policy.terraform_describe_account.arn
}

resource "aws_iam_group_policy_attachment" "administrators_terraform_assume_role_staging" {
  group      = aws_iam_group.tdr_terraform_administrators.name
  policy_arn = aws_iam_policy.staging_terraform_assume_role.arn
}

resource "aws_iam_group_policy_attachment" "administrators_terraform_assume_role_prod" {
  group      = aws_iam_group.tdr_terraform_administrators.name
  policy_arn = aws_iam_policy.prod_terraform_assume_role.arn
}

resource "aws_iam_group_policy_attachment" "administrator_access_terraform_state" {
  group      = aws_iam_group.tdr_terraform_administrators.name
  policy_arn = aws_iam_policy.read_terraform_state.arn
}

resource "aws_iam_group_policy_attachment" "administrator_change_staging_terraform_state" {
  group      = aws_iam_group.tdr_terraform_administrators.name
  policy_arn = aws_iam_policy.staging_access_terraform_state.arn
}

resource "aws_iam_group_policy_attachment" "administrator_access_terraform_state_lock" {
  group      = aws_iam_group.tdr_terraform_administrators.name
  policy_arn = aws_iam_policy.terraform_state_lock_access.arn
}

resource "aws_iam_group_policy_attachment" "administrator_change_prod_terraform_state" {
  group      = aws_iam_group.tdr_terraform_administrators.name
  policy_arn = aws_iam_policy.prod_access_terraform_state.arn
}

data "aws_ssm_parameter" "intg_account_number" {
  name = "/mgmt/intg_account"
}

data "aws_iam_policy_document" "intg_terraform_assume_role" {
  version = "2012-10-17"

  statement {
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = ["arn:aws:iam::${data.aws_ssm_parameter.intg_account_number.value}:role/intg-terraform-role"]
  }
}

data "aws_ssm_parameter" "staging_account_number" {
  name = "/mgmt/staging_account"
}

data "aws_iam_policy_document" "staging_terraform_assume_role" {
  version = "2012-10-17"

  statement {
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = ["arn:aws:iam::${data.aws_ssm_parameter.staging_account_number.value}:role/staging-terraform-role"]
  }
}

data "aws_ssm_parameter" "prod_account_number" {
  name = "/mgmt/prod_account"
}

data "aws_iam_policy_document" "prod_terraform_assume_role" {
  version = "2012-10-17"

  statement {
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = ["arn:aws:iam::${data.aws_ssm_parameter.prod_account_number.value}:role/prod-terraform-role"]
  }
}

resource "aws_iam_policy" "intg_terraform_assume_role" {
  name        = "intg_terraform_assume_role_policy"
  description = "Policy to allow terraforming of the intg TDR environment"
  policy      = data.aws_iam_policy_document.intg_terraform_assume_role.json
}

resource "aws_iam_policy" "staging_terraform_assume_role" {
  name        = "staging_terraform_assume_role_policy"
  description = "Policy to allow terraforming of the staging TDR environment"
  policy      = data.aws_iam_policy_document.staging_terraform_assume_role.json
}

resource "aws_iam_policy" "prod_terraform_assume_role" {
  name        = "prod_terraform_assume_role_policy"
  description = "Policy to allow terraforming of the production TDR environment"
  policy      = data.aws_iam_policy_document.prod_terraform_assume_role.json
}

data "aws_iam_policy_document" "read_terraform_state_bucket" {
  version = "2012-10-17"

  statement {
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [var.terraform_state_bucket]
  }
}

data "aws_iam_policy_document" "intg_write_terraform_state_bucket" {
  version = "2012-10-17"

  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:PutObject"]
    resources = ["${var.terraform_state_bucket}/env:/intg/*"]
  }
}

data "aws_iam_policy_document" "staging_write_terraform_state_bucket" {
  version = "2012-10-17"

  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:PutObject"]
    resources = ["${var.terraform_state_bucket}/env:/staging/*"]
  }
}

data "aws_iam_policy_document" "prod_write_terraform_state_bucket" {
  version = "2012-10-17"

  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:PutObject"]
    resources = ["${var.terraform_state_bucket}/env:/prod/*"]
  }
}

data "aws_iam_policy_document" "terraform_state_lock" {
  version = "2012-10-17"

  statement {
    effect    = "Allow"
    actions   = ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:DeleteItem"]
    resources = [var.terraform_state_lock]
  }
}

data "aws_iam_policy_document" "terraform_describe_account" {
  version = "2012-10-17"

  statement {
    effect    = "Allow"
    actions   = ["ec2:DescribeAccountAttributes", "ec2:DescribeAvailabilityZones"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "read_terraform_state" {
  name        = "read_terraform_state"
  description = "Policy to allow access to TDR environments' states"
  policy      = data.aws_iam_policy_document.read_terraform_state_bucket.json
}

resource "aws_iam_policy" "intg_access_terraform_state" {
  name        = "intg_access_terraform_state"
  description = "Policy to allow read/write access to intg TDR environment state"
  policy      = data.aws_iam_policy_document.intg_write_terraform_state_bucket.json
}

resource "aws_iam_policy" "staging_access_terraform_state" {
  name        = "staging_access_terraform_state"
  description = "Policy to allow read/write access to staging TDR environment state"
  policy      = data.aws_iam_policy_document.staging_write_terraform_state_bucket.json
}

resource "aws_iam_policy" "prod_access_terraform_state" {
  name        = "prod_access_terraform_state"
  description = "Policy to allow read/write access to PROD TDR environment state"
  policy      = data.aws_iam_policy_document.prod_write_terraform_state_bucket.json
}

resource "aws_iam_policy" "terraform_state_lock_access" {
  name        = "terraform_state_lock_access"
  description = "Policy to allow access to DyanmoDb to obtain lock to amend Terraform state"
  policy      = data.aws_iam_policy_document.terraform_state_lock.json
}

resource "aws_iam_policy" "terraform_describe_account" {
  name        = "terraform_describe_account"
  description = "Policy to allow terraform to describe the accounts"
  policy      = data.aws_iam_policy_document.terraform_describe_account.json
}
