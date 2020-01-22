locals {
  env_title_case = title(var.tdr_environment)
}

//IAM Roles: Jenkins Nodes Assume Roles

data "aws_iam_policy_document" "ecs_assume_role" {
  version = "2012-10-17"

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "jenkins_ecs_policy" {
  name   = "TDRJenkinsNodePolicy${local.env_title_case}"
  policy = data.aws_iam_policy_document.jenkins_node_assume_role_document.json
}

data "aws_iam_policy_document" "jenkins_node_assume_role_document" {
  statement {
    actions = ["sts:AssumeRole"]
    resources = [
      "arn:aws:iam::${var.tdr_account_number}:role/TDRJenkinsECSUpdateRole${local.env_title_case}"
    ]
  }
}

resource "aws_iam_role" "jenkins_node_assume_role" {
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json
  name               = "TDRJenkinsNodeRole${local.env_title_case}"

  tags = merge(
    var.common_tags,
    map(
      "Name", "TDR Jenkins Node Role ${local.env_title_case}",
    )
  )
}

resource "aws_iam_role" "jenkins_publish_role" {
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json
  name = "TDRJenkinsPublishRole${local.env_title_case}"
  tags = merge(
  var.common_tags,
  map(
  "Name", "TDR Jenkins Publish Role ${local.env_title_case}",
  )
  )
}

resource "aws_iam_policy" "jenkins_publish_policy" {
  name = "TDRJenkinsPublishPolicy${local.env_title_case}"
  policy = data.aws_iam_policy_document.jenkins_publish_document.json
}

data "aws_iam_policy_document" "jenkins_publish_document" {
  statement {
    actions = [
      "s3:GetObject"
    ]
    resources = [
      "arn:aws:s3:::tdr-secrets/keys/sonatype.key",
      "arn:aws:s3:::tdr-secrets/keys/sonatype_credential"
    ]
  }
}

resource "aws_iam_role_policy_attachment" "jenkins_publish_attachment" {
  policy_arn = aws_iam_policy.jenkins_publish_policy.arn
  role = aws_iam_role.jenkins_publish_role.name
}

resource "aws_iam_role_policy_attachment" "jenkins_role_attachment" {
  policy_arn = aws_iam_policy.jenkins_ecs_policy.arn
  role       = aws_iam_role.jenkins_node_assume_role.name
}


resource "aws_iam_role" "jenkins_lambda_assume_role" {
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json
  name               = "TDRJenkinsNodeLambdaRole${local.env_title_case}"

  tags = merge(
    var.common_tags,
    map(
      "Name", "TDR Jenkins Node Lambda Role ${local.env_title_case}",
    )
  )
}

resource "aws_iam_policy" "jenkins_lambda_policy" {
  name   = "TDRJenkinsNodeLambdaPolicy${local.env_title_case}"
  policy = data.aws_iam_policy_document.jenkins_node_lambda_document.json
}

data "aws_iam_policy_document" "jenkins_node_lambda_document" {
  statement {
    actions = ["sts:AssumeRole"]
    resources = [
      "arn:aws:iam::${var.tdr_account_number}:role/TDRJenkinsLambdaRole${local.env_title_case}"
    ]
  }
}

resource "aws_iam_role_policy_attachment" "jenkins_role_lambda_attachment" {
  policy_arn = aws_iam_policy.jenkins_lambda_policy.arn
  role       = aws_iam_role.jenkins_lambda_assume_role.name
}

//IAM Policies: TDR Terraform Backend Permissions

data "aws_iam_policy_document" "write_terraform_state_bucket" {
  version = "2012-10-17"

  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:PutObject"]
    resources = ["${var.terraform_state_bucket}/env:/${var.tdr_environment}/*"]
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
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = ["arn:aws:iam::${var.tdr_account_number}:role/TDRTerraformRole${local.env_title_case}"]
  }
}

resource "aws_iam_policy" "terraform_ecs_policy" {
  name   = "TDRTerraformPolicy${local.env_title_case}"
  policy = data.aws_iam_policy_document.terraform_assume_role.json
}

resource "aws_iam_role" "terraform_assume_role" {
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json
  name               = "TDRTerraformAssumeRole${local.env_title_case}"

  tags = merge(
    var.common_tags,
    map(
      "Name", "TDR Terraform Assume Role ${local.env_title_case}",
    )
  )
}

resource "aws_iam_role_policy_attachment" "terraform_role_attachment" {
  role       = aws_iam_role.terraform_assume_role.name
  policy_arn = aws_iam_policy.terraform_ecs_policy.arn
}

resource "aws_iam_role_policy_attachment" "terraform_role_access_terraform_state" {
  role       = aws_iam_role.terraform_assume_role.name
  policy_arn = var.read_terraform_state_policy_arn
}

resource "aws_iam_role_policy_attachment" "terraform_role_change_terraform_state" {
  role       = aws_iam_role.terraform_assume_role.name
  policy_arn = aws_iam_policy.access_terraform_state.arn
}

resource "aws_iam_role_policy_attachment" "terraform_role_access_terraform_state_lock" {
  role       = aws_iam_role.terraform_assume_role.name
  policy_arn = var.terraform_state_lock_access_arn
}

resource "aws_iam_role_policy_attachment" "terraform_role_describe_accounts" {
  role       = aws_iam_role.terraform_assume_role.name
  policy_arn = var.terraform_describe_account_arn
}
