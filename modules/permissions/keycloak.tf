data "aws_caller_identity" "current" {}

resource "aws_iam_policy" "jenkins_logs_policy" {
  policy = data.aws_iam_policy_document.jenkins_logs_document.json
  name = "JenkinsLogs"
}

data "aws_iam_policy_document" "jenkins_logs_document" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:DeleteLogGroup",
      "logs:DeleteLogStream",
      "logs:DescribeLogStreams",
      "logs:PutRetentionPolicy"
    ]
    resources = [
      "arn:aws:logs:eu-west-2:*:log-group:*"
    ]
  }

  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:DescribeLogGroups",
      "logs:ListTagsLogGroup"
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_policy" "jenkins_ssm_policy" {
  policy = data.aws_iam_policy_document.jenkins_ssm_document.json
  name = "JenkinsSsm"
}

data "aws_iam_policy_document" "jenkins_ssm_document" {
  statement {
    actions = [
      "ssm:AddTagsToResource",
      "ssm:DeleteParameter",
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:ListTagsForResource",
      "ssm:PutParameter"
    ]
    resources = [

    ]
  }

  statement {
    actions = [
      "ssm:DescribeParameters"
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_policy" "jenkins_iam_policy" {
  policy = data.aws_iam_policy_document.jenkins_iam_document.json
  name = "JenkinsIam"
}

data "aws_iam_policy_document" "jenkins_iam_document" {
  statement {
    actions = [
      "iam:AttachRolePolicy",
      "iam:CreatePolicy",
      "iam:CreateRole",
      "iam:DeletePolicy",
      "iam:DeleteRole",
      "iam:DetachRolePolicy",
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:GetRole",
      "iam:ListAttachedRolePolicies",
      "iam:ListPolicyVersions",
      "iam:PassRole",
      "iam:TagRole",
      "iam:UpdateAssumeRolePolicy"
    ]
    resources = [
      "arn:aws:iam::328920706552:policy/keycloak_ecs_execution_policy_${var.environment}",
      "arn:aws:iam::328920706552:role/keycloak_ecs_execution_role_${var.environment}",
      "arn:aws:iam::328920706552:role/keycloak_ecs_task_role_${var.environment}"
    ]
  }
}

resource "aws_iam_policy" "jenkins_elb_policy" {
  policy = data.aws_iam_policy_document.jenkins_elb_document.json
  name = "JenkinsElb"
}

data "aws_iam_policy_document" "jenkins_elb_document" {
  statement {
    actions = [
      "elasticloadbalancing:AddTags",
      "elasticloadbalancing:CreateListener",
      "elasticloadbalancing:CreateLoadBalancer",
      "elasticloadbalancing:DeleteListener",
      "elasticloadbalancing:DeleteLoadBalancer",
      "elasticloadbalancing:DeleteTargetGroup",
      "elasticloadbalancing:DeregisterTargets",
      "elasticloadbalancing:ModifyLoadBalancerAttributes",
      "elasticloadbalancing:ModifyTargetGroupAttributes",
      "elasticloadbalancing:RegisterTargets"
    ]
    resources = [
      "arn:aws:elasticloadbalancing:eu-west-2:328920706552:listener/app/tdr-keycloak-load-balancer-${var.environment}/*/*",
      "arn:aws:elasticloadbalancing:eu-west-2:328920706552:listener/net/tdr-keycloak-load-balancer-${var.environment}/*/*",
      "arn:aws:elasticloadbalancing:eu-west-2:328920706552:loadbalancer/net/tdr-keycloak-load-balancer-${var.environment}/*",
      "arn:aws:elasticloadbalancing:eu-west-2:328920706552:targetgroup/*"
    ]
  }

  statement {
    actions = [
      "elasticloadbalancing:CreateTargetGroup",
      "elasticloadbalancing:DescribeListeners",
      "elasticloadbalancing:DescribeLoadBalancerAttributes",
      "elasticloadbalancing:DescribeLoadBalancers",
      "elasticloadbalancing:DescribeTags",
      "elasticloadbalancing:DescribeTargetGroupAttributes",
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:DescribeTargetHealth"
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_policy" "jenkins_ecs_policy" {
  policy = data.aws_iam_policy_document.jenkins_ecs_document.json
  name = "JenkinsEcs"
}

data "aws_iam_policy_document" "jenkins_ecs_document" {
  statement {
    actions = [
      "ecs:CreateService",
      "ecs:DeleteCluster",
      "ecs:DeleteService",
      "ecs:DescribeServices",
      "ecs:UpdateService"
    ]
    resources = [
      "arn:aws:ecs:eu-west-2:328920706552:cluster/keycloak-ecs-${var.environment}",
      "arn:aws:ecs:eu-west-2:328920706552:service/keycloak-ecs-${var.environment}/keycloak-service-${var.environment}"
    ]
  }

  statement {
    actions = [
      "ecs:CreateCluster",
      "ecs:DeregisterTaskDefinition",
      "ecs:DescribeTaskDefinition",
      "ecs:RegisterTaskDefinition"
    ]
    resources = [
      "*"
    ]
  }
}


resource "aws_iam_group" "terraform_jenkins" {
  name = "terraform-jenkins"
}

resource "aws_iam_group_policy_attachment" "jenkins_ecs_attach" {
  group = aws_iam_group.terraform_jenkins.name
  policy_arn = aws_iam_policy.jenkins_ecs_policy.arn
}
resource "aws_iam_group_policy_attachment" "jenkins_elb_attach" {
  group = aws_iam_group.terraform_jenkins.name
  policy_arn = aws_iam_policy.jenkins_elb_policy.arn
}
resource "aws_iam_group_policy_attachment" "jenkins_iam_attach" {
  group = aws_iam_group.terraform_jenkins.name
  policy_arn = aws_iam_policy.jenkins_iam_policy.arn
}
resource "aws_iam_group_policy_attachment" "jenkins_ssm_attach" {
  group = aws_iam_group.terraform_jenkins.name
  policy_arn = aws_iam_policy.jenkins_ssm_policy.arn
}
resource "aws_iam_group_policy_attachment" "jenkins_logs_attach" {
  group = aws_iam_group.terraform_jenkins.name
  policy_arn = aws_iam_policy.jenkins_logs_policy.arn
}

