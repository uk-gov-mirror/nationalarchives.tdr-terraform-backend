data "aws_caller_identity" "current" {}

resource "aws_iam_policy" "terraform_create_jenkins_a" {
  policy = data.aws_iam_policy_document.terraform_create_jenkins_document_a.json
  name = "terraform_create_jenkins_a"
}

resource "aws_iam_policy" "terraform_create_jenkins_b" {
  policy = data.aws_iam_policy_document.terraform_create_jenkins_document_b.json
  name = "terraform_create_jenkins_b"
}

data "aws_iam_policy_document" "terraform_create_jenkins_document_a" {

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
      "arn:aws:elasticloadbalancing:eu-west-2:${data.aws_caller_identity.current.account_id}:listener/app/tdr-jenkins-load-balancer-${var.environment}/*/*",
      "arn:aws:elasticloadbalancing:eu-west-2:${data.aws_caller_identity.current.account_id}:listener/net/tdr-jenkins-load-balancer-${var.environment}/*/*",
      "arn:aws:elasticloadbalancing:eu-west-2:${data.aws_caller_identity.current.account_id}:loadbalancer/net/tdr-jenkins-load-balancer-${var.environment}/*",
      "arn:aws:elasticloadbalancing:eu-west-2:${data.aws_caller_identity.current.account_id}:targetgroup/*"
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

  statement {
    actions = [
      "cloudfront:CreateDistribution",
      "cloudfront:CreateDistributionWithTags",
      "cloudfront:DeleteDistribution",
      "cloudfront:GetDistribution",
      "cloudfront:ListTagsForResource",
      "cloudfront:TagResource",
      "cloudfront:UpdateDistribution"
    ]
    resources = [
      "arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/*"
    ]
  }

  statement {
    actions = [
      "ecs:CreateService",
      "ecs:DeleteCluster",
      "ecs:DeleteService",
      "ecs:DescribeServices",
      "ecs:UpdateService",
      "ecs:DescribeClusters"
    ]
    resources = [
      "arn:aws:ecs:eu-west-2:${data.aws_caller_identity.current.account_id}:cluster/jenkins-${var.environment}",
      "arn:aws:ecs:eu-west-2:${data.aws_caller_identity.current.account_id}:service/jenkins-${var.environment}/jenkins-service-${var.environment}"
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

  statement {
    actions   = [
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:CreateRoute",
      "ec2:DeleteSecurityGroup",
      "ec2:RevokeSecurityGroupEgress",
      "ec2:RevokeSecurityGroupIngress",
      "ec2:TerminateInstances",
      "ec2:DescribeAccountAttributes"
    ]
    resources = [
      "arn:aws:ec2:eu-west-2:${data.aws_caller_identity.current.account_id}:instance/*",
      "arn:aws:ec2:eu-west-2:${data.aws_caller_identity.current.account_id}:route-table/*",
      "arn:aws:ec2:eu-west-2:${data.aws_caller_identity.current.account_id}:security-group/*",
      "arn:aws:ec2:eu-west-2:${data.aws_caller_identity.current.account_id}:vpc/*"
    ]
  }

  statement {
    actions = [
      "ec2:AllocateAddress",
      "ec2:AssociateRouteTable",
      "ec2:AttachInternetGateway",
      "ec2:AuthorizeSecurityGroupEgress",
      "ec2:CreateInternetGateway",
      "ec2:CreateNatGateway",
      "ec2:CreateNetworkInterface",
      "ec2:CreateRouteTable",
      "ec2:CreateSecurityGroup",
      "ec2:CreateSubnet",
      "ec2:CreateTags",
      "ec2:CreateVpc",
      "ec2:DeleteInternetGateway",
      "ec2:DeleteKeyPair",
      "ec2:DeleteNatGateway",
      "ec2:DeleteNetworkInterface",
      "ec2:DeleteRoute",
      "ec2:DeleteRouteTable",
      "ec2:DeleteSubnet",
      "ec2:DeleteVpc",
      "ec2:DescribeAddresses",
      "ec2:DescribeInstanceAttribute",
      "ec2:DescribeInstanceCreditSpecifications",
      "ec2:DescribeInstances",
      "ec2:DescribeInternetGateways",
      "ec2:DescribeKeyPairs",
      "ec2:DescribeNatGateways",
      "ec2:DescribeNetworkAcls",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeRouteTables",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSubnets",
      "ec2:DescribeTags",
      "ec2:DescribeVolumes",
      "ec2:DescribeVpcAttribute",
      "ec2:DescribeVpcs",
      "ec2:DetachInternetGateway",
      "ec2:DetachNetworkInterface",
      "ec2:DisassociateRouteTable",
      "ec2:ImportKeyPair",
      "ec2:ModifyNetworkInterfaceAttribute",
      "ec2:ModifySubnetAttribute",
      "ec2:ReleaseAddress",
      "ec2:RunInstances",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeImages"
    ]
    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:GetObjectTagging"]
    resources = ["${var.terraform_jenkins_state_bucket}/*", "arn:aws:s3:::tdr-secrets/mgmt/secrets.yml"]
  }

  statement {
    effect = "Allow"
    actions = ["s3:ListBucket"]
    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:DeleteItem"]
    resources = [var.terraform_jenkins_state_lock]
  }
}

data "aws_iam_policy_document" "terraform_create_jenkins_document_b" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:DeleteLogGroup",
      "logs:DeleteLogStream",
      "logs:DescribeLogStreams",
      "logs:CreateLogGroup",
      "logs:PutRetentionPolicy",
      "logs:ListTagsLogGroup"
    ]
    resources = [
      "arn:aws:logs:eu-west-2:${data.aws_caller_identity.current.account_id}:log-group:*"
    ]
  }

  statement {
    actions = [
      "logs:DescribeLogGroups",
    ]
    resources = [
      "*"
    ]
  }

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
      "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/${var.environment}/access_key",
      "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/${var.environment}/secret_key",
      "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/${var.environment}/fargate_security_group",
      "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/${var.environment}/github/client",
      "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/${var.environment}/github/secret",
      "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/${var.environment}/jenkins_url",
      "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/${var.environment}/create_keycloak_access_key",
      "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/${var.environment}/create_keycloak_secret_key",
      "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/${var.environment}/github/username",
      "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/${var.environment}/github/password",
      "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/${var.environment}/docker/username",
      "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/${var.environment}/docker/password",
      "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/${var.environment}/slack/token"
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

  statement {
    actions = [
      "lambda:AddPermission",
      "lambda:CreateFunction",
      "lambda:DeleteFunction",
      "lambda:GetFunction",
      "lambda:GetPolicy",
      "lambda:ListVersionsByFunction",
      "lambda:RemovePermission"
    ]
    resources = [
      "arn:aws:lambda:eu-west-2:${data.aws_caller_identity.current.account_id}:function:tdr-jenkins-sg-update-${var.environment}"
    ]
  }

  statement {
    actions = [
      "iam:AddRoleToInstanceProfile",
      "iam:AttachRolePolicy",
      "iam:CreateInstanceProfile",
      "iam:CreatePolicy",
      "iam:CreateRole",
      "iam:DeletePolicy",
      "iam:DeleteRole",
      "iam:DetachRolePolicy",
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:GetRole",
      "iam:ListAttachedRolePolicies",
      "iam:ListInstanceProfilesForRole",
      "iam:ListPolicyVersions",
      "iam:PassRole",
      "iam:TagRole",
      "iam:UpdateAssumeRolePolicy",
      "iam:GetInstanceProfile",
      "iam:CreateGroup",
      "iam:GetGroup",
      "iam:DeleteGroup",
      "iam:AttachGroupPolicy",
      "iam:DetachGroupPolicy",
      "iam:ListAttachedGroupPolicies",
      "iam:CreatePolicyVersion"
    ]
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:instance-profile/jenkins_instance_profile_${var.environment}",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:group/jenkins-fargate-${var.environment}",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/api_ecs_execution_policy_${var.environment}",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/invoke-jenkins-sg-update-api-gateway_${var.environment}",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/jenkins_ec2_policy_${var.environment}",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/jenkins_fargate_policy_${var.environment}",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/api_ecs_execution_role_${var.environment}",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/api_ecs_task_role_${var.environment}",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/ecs.amazonaws.com/AWSServiceRoleForECS",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ecsExecutionRole",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ecsTaskRole",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/jenkins_fargate_role_${var.environment}",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/jenkins_lambda_role_${var.environment}",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/jenkins-sg-update_lambda_role_${var.environment}"
    ]
  }

  statement {
    actions = [
      "iam:DeleteInstanceProfile",
      "iam:RemoveRoleFromInstanceProfile"
    ]
    resources = [
      "*"
    ]
  }

}

resource "aws_iam_group" "terraform_jenkins" {
  name = "terraform-create-jenkins"
}

resource "aws_iam_group_policy_attachment" "jenkins_policy_a_attach" {
  group = aws_iam_group.terraform_jenkins.name
  policy_arn = aws_iam_policy.terraform_create_jenkins_a.arn
}

resource "aws_iam_group_policy_attachment" "jenkins_policy_b_attach" {
  group = aws_iam_group.terraform_jenkins.name
  policy_arn = aws_iam_policy.terraform_create_jenkins_b.arn
}

