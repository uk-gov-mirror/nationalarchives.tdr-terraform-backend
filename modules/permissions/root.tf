//Developers can only Terraform the CI environment
resource "aws_iam_group" "tdr_terraform_developers" {
  name = "tdr-terraform-developers"
}

//Administrators can Terraform all environments
resource "aws_iam_group" "tdr_terraform_administrators" {
  name = "tdr-terraform-administrators"
}

resource "aws_iam_group_policy_attachment" "developers_terraform_assume_role_ci" {
  group      = aws_iam_group.tdr_terraform_developers.name
  policy_arn = aws_iam_policy.ci_terraform_assume_role.arn
}

resource "aws_iam_group_policy_attachment" "developers_access_terraform_state" {
  group      = aws_iam_group.tdr_terraform_developers.name
  policy_arn = aws_iam_policy.read_terraform_state.arn
}

resource "aws_iam_group_policy_attachment" "developers_change_terraform_state" {
  group      = aws_iam_group.tdr_terraform_developers.name
  policy_arn = aws_iam_policy.ci_access_terraform_state.arn
}

resource "aws_iam_group_policy_attachment" "developers_access_terraform_state_lock" {
  group      = aws_iam_group.tdr_terraform_developers.name
  policy_arn = aws_iam_policy.terraform_state_lock_access.arn
}

resource "aws_iam_group_policy_attachment" "administrators_terraform_assume_role_test" {
  group      = aws_iam_group.tdr_terraform_administrators.name
  policy_arn = aws_iam_policy.test_terraform_assume_role.arn
}

resource "aws_iam_group_policy_attachment" "administrators_terraform_assume_role_prod" {
  group      = aws_iam_group.tdr_terraform_administrators.name
  policy_arn = aws_iam_policy.prod_terraform_assume_role.arn
}

resource "aws_iam_group_policy_attachment" "administrator_access_terraform_state" {
  group      = aws_iam_group.tdr_terraform_administrators.name
  policy_arn = aws_iam_policy.read_terraform_state.arn
}

resource "aws_iam_group_policy_attachment" "administrator_change_test_terraform_state" {
  group      = aws_iam_group.tdr_terraform_administrators.name
  policy_arn = aws_iam_policy.test_access_terraform_state.arn
}

resource "aws_iam_group_policy_attachment" "administrator_change_prod_terraform_state" {
  group      = aws_iam_group.tdr_terraform_administrators.name
  policy_arn = aws_iam_policy.prod_access_terraform_state.arn
}

data "aws_iam_policy_document" "ci_terraform_assume_role" {
  version = "2012-10-17"

  statement {
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    //This should be the arn to the Terraform role defined for the environment
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "test_terraform_assume_role" {
  version = "2012-10-17"

  statement {
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    //This should be the arn to the Terraform role defined for the environment
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "prod_terraform_assume_role" {
  version = "2012-10-17"

  statement {
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    //This should be the arn to the Terraform role defined for the environment
    resources = ["*"]
  }
}

resource "aws_iam_policy" "ci_terraform_assume_role" {
  name        = "ci_terraform_assume_role_policy"
  description = "Policy to allow terraforming of the CI TDR environment"
  policy      = data.aws_iam_policy_document.ci_terraform_assume_role.json
}

resource "aws_iam_policy" "test_terraform_assume_role" {
  name        = "test_terraform_assume_role_policy"
  description = "Policy to allow terraforming of the test TDR environment"
  policy      = data.aws_iam_policy_document.test_terraform_assume_role.json
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

data "aws_iam_policy_document" "ci_write_terraform_state_bucket" {
  version = "2012-10-17"

  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:PutObject"]
    resources = ["${var.terraform_state_bucket}/env:/ci"]
  }
}

data "aws_iam_policy_document" "test_write_terraform_state_bucket" {
  version = "2012-10-17"

  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:PutObject"]
    resources = ["${var.terraform_state_bucket}/env:/test"]
  }
}

data "aws_iam_policy_document" "prod_write_terraform_state_bucket" {
  version = "2012-10-17"

  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:PutObject"]
    resources = ["${var.terraform_state_bucket}/env:/prod"]
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

resource "aws_iam_policy" "read_terraform_state" {
  name        = "read_terraform_state"
  description = "Policy to allow access to TDR environments' states"
  policy      = data.aws_iam_policy_document.read_terraform_state_bucket.json
}

resource "aws_iam_policy" "ci_access_terraform_state" {
  name        = "ci_access_terraform_state"
  description = "Policy to allow read/write access to CI TDR environment state"
  policy      = data.aws_iam_policy_document.ci_write_terraform_state_bucket.json
}

resource "aws_iam_policy" "test_access_terraform_state" {
  name        = "test_access_terraform_state"
  description = "Policy to allow read/write access to TEST TDR environment state"
  policy      = data.aws_iam_policy_document.test_write_terraform_state_bucket.json
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
