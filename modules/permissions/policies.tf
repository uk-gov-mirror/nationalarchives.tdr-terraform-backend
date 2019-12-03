resource "aws_iam_policy" "terraform_apply_policy" {
  policy = data.aws_iam_policy_document.terraform_apply_global_document.json
  name = "TerraformApply"
}

data "aws_iam_policy_document" "terraform_apply_global_document" {
  statement {
    actions = [
      "iam:GetRole",
      "s3:PutObject",
      "s3:GetObject",
      "iam:GetInstanceProfile",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
      "dynamodb:GetItem",
      "s3:GetObjectTagging",
      "s3:ListBucket",
      "ecs:DescribeClusters"
    ]
    resources = [
      "arn:aws:iam::328920706552:role/jenkins_lambda_role_${var.environment}",
      "arn:aws:iam::328920706552:role/jenkins_fargate_role_${var.environment}",
      "arn:aws:iam::328920706552:role/jenkins-sg-update_lambda_ role_${var.environment}",
      "arn:aws:iam::328920706552:instance-profile/jenkins_instance_profile_${var.environment}",
      "arn:aws:s3:::tdr-secrets/${var.environment}/secrets.yml",
      "arn:aws:s3:::tdr-terraform-state-jenkins/*",
      "arn:aws:s3:::tdr-secrets",
      "arn:aws:s3:::tdr-terraform-state-jenkins",
      "arn:aws:ecs:eu-west-2:328920706552:cluster/*",
      "arn:aws:dynamodb:eu-west-2:328920706552:table/tdr-terraform-state-lock-jenkins"
    ]
  }
  statement {
    actions = [
      "ec2:DescribeImages",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeAccountAttributes"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_group" "terraform_apply" {
  name = "terraform-apply"
}

resource "aws_iam_group_policy_attachment" "jenkins_ec2_attach" {
  group = aws_iam_group.terraform_apply.name
  policy_arn = aws_iam_policy.terraform_apply_policy.arn
}
