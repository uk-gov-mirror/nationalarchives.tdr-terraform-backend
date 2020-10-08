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
    resources = [var.terraform_state_bucket, var.terraform_scripts_state_bucket]
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
    resources = [var.terraform_state_lock, var.terraform_scripts_state_lock]
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

resource "aws_iam_role" "jenkins_publish_role" {
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json
  name               = "TDRJenkinsPublishRole"
  tags = merge(
    var.common_tags,
    map(
      "Name", "TDR Jenkins Publish Role",
    )
  )
}

resource "aws_iam_policy" "jenkins_publish_policy" {
  name   = "TDRJenkinsPublishPolicy"
  policy = data.aws_iam_policy_document.jenkins_publish_document.json
}

data "aws_iam_policy_document" "jenkins_publish_document" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket"
    ]
    resources = [
      var.release_bucket_arn,
      var.staging_bucket_arn,
      "${var.release_bucket_arn}/*",
      "${var.staging_bucket_arn}/*"
    ]
  }
}

resource "aws_iam_role_policy_attachment" "jenkins_publish_attachment" {
  policy_arn = aws_iam_policy.jenkins_publish_policy.arn
  role       = aws_iam_role.jenkins_publish_role.name
}

data "aws_iam_policy_document" "custodian_get_parameters" {
  version = "2012-10-17"

  statement {
    effect    = "Allow"
    actions   = ["ssm:GetParameter"]
    resources = ["arn:aws:ssm:eu-west-2:*:parameter/mgmt/cost_centre", "arn:aws:ssm:eu-west-2:*:parameter/mgmt/slack/webhook"]
  }
}

resource "aws_iam_policy" "custodian_get_parameters" {
  name        = "TDRCustodianGetParameters"
  description = "Policy to allow Cloud Custodian to get SSM parameters"
  policy      = data.aws_iam_policy_document.custodian_get_parameters.json
}


resource "aws_iam_role" "jenkins_lambda_deploy_role" {
  name               = "TDRJenkinsNodeLambdaRoleMgmt"
  assume_role_policy = templatefile("${path.module}/templates/ecs_assume_role_policy.json.tpl", {})
}

resource "aws_iam_policy" "jenkins_lambda_deploy_policy" {
  name   = "TDRJenkinsNodeLambdaPolicyMgmt"
  policy = templatefile("${path.module}/templates/jenkins_lambda_deploy_policy.json.tpl", { account_id = var.management_account_number })
}

resource "aws_iam_role_policy_attachment" "jenkins_lambda_deploy_attach" {
  policy_arn = aws_iam_policy.jenkins_lambda_deploy_policy.arn
  role       = aws_iam_role.jenkins_lambda_deploy_role.id
}
