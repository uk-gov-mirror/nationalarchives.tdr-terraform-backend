//Developers can only Terraform the CI environment
resource "aws_iam_group" "tdr_management_developers" {
  name = "tdr-management-developers"
}

//Administrators can Terraform all environments
resource "aws_iam_group" "tdr_management_administrators" {
  name = "tdr-management-administrators"
}

resource "aws_iam_group_policy_attachment" "developers_terraform_assume_role" {
  group      = aws_iam_group.tdr_management_developers.name
  policy_arn = aws_iam_policy.ci_terraform_assume_role.arn
}

resource "aws_iam_group_policy_attachment" "administrators_terraform_assume_role_test" {
  group      = aws_iam_group.tdr_management_administrators.name
  policy_arn = aws_iam_policy.test_terraform_assume_role.arn
}

resource "aws_iam_group_policy_attachment" "administrators_terraform_assume_role_prod" {
  group      = aws_iam_group.tdr_management_administrators.name
  policy_arn = aws_iam_policy.prod_terraform_assume_role.arn
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
