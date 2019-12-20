//IAM Group: Deny All Access

resource "aws_iam_group" "tdr_deny_access" {
  name = "TDRDenyAccess"
}

resource "aws_iam_group_policy_attachment" "deny_all_access" {
  group      = aws_iam_group.tdr_deny_access.name
  policy_arn = "arn:aws:iam::aws:policy/AWSDenyAll"
}

//TDR Environment Account Numbers

data "aws_ssm_parameter" "intg_account_number" {
  name = "/mgmt/intg_account"
}

data "aws_ssm_parameter" "staging_account_number" {
  name = "/mgmt/staging_account"
}

data "aws_ssm_parameter" "prod_account_number" {
  name = "/mgmt/prod_account"
}

//IAM Policies: TDR Terraform Backend Permissions

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
  name        = "TDRReadTerraformState"
  description = "Policy to allow access to TDR environments' states"
  policy      = data.aws_iam_policy_document.read_terraform_state_bucket.json
}

resource "aws_iam_policy" "intg_access_terraform_state" {
  name        = "TDRIntgAccessTerraformState"
  description = "Policy to allow read/write access to intg TDR environment state"
  policy      = data.aws_iam_policy_document.intg_write_terraform_state_bucket.json
}

resource "aws_iam_policy" "staging_access_terraform_state" {
  name        = "TDRStagingAccessTerraformState"
  description = "Policy to allow read/write access to staging TDR environment state"
  policy      = data.aws_iam_policy_document.staging_write_terraform_state_bucket.json
}

resource "aws_iam_policy" "prod_access_terraform_state" {
  name        = "TDRProdAccessTerraformState"
  description = "Policy to allow read/write access to PROD TDR environment state"
  policy      = data.aws_iam_policy_document.prod_write_terraform_state_bucket.json
}

resource "aws_iam_policy" "terraform_state_lock_access" {
  name        = "TDRTerraformStateLockAccess"
  description = "Policy to allow access to DyanmoDb to obtain lock to amend Terraform state"
  policy      = data.aws_iam_policy_document.terraform_state_lock.json
}

resource "aws_iam_policy" "terraform_describe_account" {
  name        = "TDRTerraformDescribeAccount"
  description = "Policy to allow terraform to describe the accounts"
  policy      = data.aws_iam_policy_document.terraform_describe_account.json
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

data "aws_iam_policy_document" "jenkins_node_assume_role_document_intg" {
  statement {
    actions = ["sts:AssumeRole"]
    resources = [
      "arn:aws:iam::${data.aws_ssm_parameter.intg_account_number.value}:role/TDRJenkinsECSUpdateRoleIntg"
    ]
  }
}

resource "aws_iam_policy" "jenkins_ecs_policy_intg" {
  name   = "TDRJenkinsNodePolicyIntg"
  policy = data.aws_iam_policy_document.jenkins_node_assume_role_document_intg.json
}

resource "aws_iam_role" "jenkins_node_assume_role_intg" {
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json
  name               = "TDRJenkinsNodeRoleIntg"

  tags = merge(
    var.common_tags,
    map(
      "Name", "TDR Jenkins Node Role Intg",
    )
  )
}

resource "aws_iam_role_policy_attachment" "jenkins_role_attachment_intg" {
  policy_arn = aws_iam_policy.jenkins_ecs_policy_intg.arn
  role       = aws_iam_role.jenkins_node_assume_role_intg.name
}

data "aws_iam_policy_document" "jenkins_node_assume_role_document_staging" {
  statement {
    actions = ["sts:AssumeRole"]
    resources = [
      "arn:aws:iam::${data.aws_ssm_parameter.staging_account_number.value}:role/TDRJenkinsECSUpdateRoleStaging"
    ]
  }
}

resource "aws_iam_policy" "jenkins_ecs_policy_staging" {
  name   = "TDRJenkinsNodePolicyStaging"
  policy = data.aws_iam_policy_document.jenkins_node_assume_role_document_staging.json
}

resource "aws_iam_role" "jenkins_node_assume_role_staging" {
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json
  name               = "TDRJenkinsNodeRoleStaging"

  tags = merge(
    var.common_tags,
    map(
      "Name", "TDR Jenkins Node Role Staging",
    )
  )
}

resource "aws_iam_role_policy_attachment" "jenkins_role_attachment_staging" {
  policy_arn = aws_iam_policy.jenkins_ecs_policy_staging.arn
  role       = aws_iam_role.jenkins_node_assume_role_staging.name
}

data "aws_iam_policy_document" "jenkins_node_assume_role_document_prod" {
  statement {
    actions = ["sts:AssumeRole"]
    resources = [
      "arn:aws:iam::${data.aws_ssm_parameter.prod_account_number.value}:role/TDRJenkinsECSUpdateRoleProd"
    ]
  }
}

resource "aws_iam_policy" "jenkins_ecs_policy_prod" {
  name   = "TDRJenkinsNodePolicyProd"
  policy = data.aws_iam_policy_document.jenkins_node_assume_role_document_prod.json
}

resource "aws_iam_role" "jenkins_node_assume_role_prod" {
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json
  name               = "TDRJenkinsNodeRoleProd"

  tags = merge(
    var.common_tags,
    map(
      "Name", "TDR Jenkins Node Role Prod",
    )
  )
}

resource "aws_iam_role_policy_attachment" "jenkins_role_attachment_prod" {
  policy_arn = aws_iam_policy.jenkins_ecs_policy_prod.arn
  role       = aws_iam_role.jenkins_node_assume_role_prod.name
}

//IAM Roles: Terraform Assume Roles

data "aws_iam_policy_document" "intg_terraform_assume_role" {
  version = "2012-10-17"

  statement {
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = ["arn:aws:iam::${data.aws_ssm_parameter.intg_account_number.value}:role/TDRTerraformRoleIntg"]
  }
}

resource "aws_iam_policy" "terraform_ecs_policy_intg" {
  name   = "TDRTerraformPolicyIntg"
  policy = data.aws_iam_policy_document.intg_terraform_assume_role.json
}

resource "aws_iam_role" "terraform_assume_role_intg" {
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json
  name               = "TDRTerraformAssumeRoleIntg"

  tags = merge(
    var.common_tags,
    map(
      "Name", "TDR Terraform Assume Role Intg",
    )
  )
}

resource "aws_iam_role_policy_attachment" "terraform_role_attachment_intg" {
  role       = aws_iam_role.terraform_assume_role_intg.name
  policy_arn = aws_iam_policy.terraform_ecs_policy_intg.arn
}

resource "aws_iam_role_policy_attachment" "intg_terraform_role_access_terraform_state" {
  role       = aws_iam_role.terraform_assume_role_intg.name
  policy_arn = aws_iam_policy.read_terraform_state.arn
}

resource "aws_iam_role_policy_attachment" "intg_terraform_role_change_terraform_state" {
  role       = aws_iam_role.terraform_assume_role_intg.name
  policy_arn = aws_iam_policy.intg_access_terraform_state.arn
}

resource "aws_iam_role_policy_attachment" "intg_terraform_role_access_terraform_state_lock" {
  role       = aws_iam_role.terraform_assume_role_intg.name
  policy_arn = aws_iam_policy.terraform_state_lock_access.arn
}

resource "aws_iam_role_policy_attachment" "intg_terraform_role_describe_accounts" {
  role       = aws_iam_role.terraform_assume_role_intg.name
  policy_arn = aws_iam_policy.terraform_describe_account.arn
}

data "aws_iam_policy_document" "staging_terraform_assume_role" {
  version = "2012-10-17"

  statement {
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = ["arn:aws:iam::${data.aws_ssm_parameter.staging_account_number.value}:role/TDRTerraformRoleStaging"]
  }
}

resource "aws_iam_policy" "terraform_ecs_policy_staging" {
  name   = "TDRTerraformPolicyStaging"
  policy = data.aws_iam_policy_document.staging_terraform_assume_role.json
}

resource "aws_iam_role" "terraform_assume_role_staging" {
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json
  name               = "TDRTerraformAssumeRoleStaging"

  tags = merge(
    var.common_tags,
    map(
      "Name", "TDR Terraform Assume Role Staging",
    )
  )
}

resource "aws_iam_role_policy_attachment" "terraform_role_attachment_staging" {
  policy_arn = aws_iam_policy.terraform_ecs_policy_staging.arn
  role       = aws_iam_role.terraform_assume_role_staging.name
}

resource "aws_iam_role_policy_attachment" "staging_terraform_role_access_terraform_state" {
  role       = aws_iam_role.terraform_assume_role_staging.name
  policy_arn = aws_iam_policy.read_terraform_state.arn
}

resource "aws_iam_role_policy_attachment" "staging_terraform_role_change_terraform_state" {
  role       = aws_iam_role.terraform_assume_role_staging.name
  policy_arn = aws_iam_policy.intg_access_terraform_state.arn
}

resource "aws_iam_role_policy_attachment" "staging_terraform_role_access_terraform_state_lock" {
  role       = aws_iam_role.terraform_assume_role_staging.name
  policy_arn = aws_iam_policy.terraform_state_lock_access.arn
}

resource "aws_iam_role_policy_attachment" "staging_terraform_role_describe_accounts" {
  role       = aws_iam_role.terraform_assume_role_staging.name
  policy_arn = aws_iam_policy.terraform_describe_account.arn
}

data "aws_iam_policy_document" "prod_terraform_assume_role" {
  version = "2012-10-17"

  statement {
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = ["arn:aws:iam::${data.aws_ssm_parameter.prod_account_number.value}:role/TDRTerraformRoleProd"]
  }
}

resource "aws_iam_policy" "terraform_ecs_policy_prod" {
  name   = "TDRTerraformPolicyProd"
  policy = data.aws_iam_policy_document.prod_terraform_assume_role.json
}

resource "aws_iam_role" "terraform_assume_role_prod" {
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json
  name               = "TDRTerraformAssumeRoleProd"

  tags = merge(
    var.common_tags,
    map(
      "Name", "TDR Terraform Assume Role Prod",
    )
  )
}

resource "aws_iam_role_policy_attachment" "terraform_role_attachment_prod" {
  policy_arn = aws_iam_policy.terraform_ecs_policy_prod.arn
  role       = aws_iam_role.terraform_assume_role_prod.name
}

resource "aws_iam_role_policy_attachment" "prod_terraform_role_access_terraform_state" {
  role       = aws_iam_role.terraform_assume_role_prod.name
  policy_arn = aws_iam_policy.read_terraform_state.arn
}

resource "aws_iam_role_policy_attachment" "prod_terraform_role_change_terraform_state" {
  role       = aws_iam_role.terraform_assume_role_prod.name
  policy_arn = aws_iam_policy.intg_access_terraform_state.arn
}

resource "aws_iam_role_policy_attachment" "prod_terraform_role_access_terraform_state_lock" {
  role       = aws_iam_role.terraform_assume_role_prod.name
  policy_arn = aws_iam_policy.terraform_state_lock_access.arn
}

resource "aws_iam_role_policy_attachment" "prod_terraform_role_describe_accounts" {
  role       = aws_iam_role.terraform_assume_role_prod.name
  policy_arn = aws_iam_policy.terraform_describe_account.arn
}
