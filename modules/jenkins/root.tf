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
      "arn:aws:logs:eu-west-2:328920706552:log-group:*"
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
      "arn:aws:ssm:eu-west-2:328920706552:parameter/${var.environment}/access_key",
      "arn:aws:ssm:eu-west-2:328920706552:parameter/${var.environment}/fargate_security_group",
      "arn:aws:ssm:eu-west-2:328920706552:parameter/${var.environment}/github/client",
      "arn:aws:ssm:eu-west-2:328920706552:parameter/${var.environment}/github/secret",
      "arn:aws:ssm:eu-west-2:328920706552:parameter/${var.environment}/jenkins_url",
      "arn:aws:ssm:eu-west-2:328920706552:parameter/${var.environment}/secret_key"
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

resource "aws_iam_policy" "jenkins_lambda_policy" {
  policy = data.aws_iam_policy_document.jenkins_lambda_document.json
  name = "JenkinsLambda"
}

data "aws_iam_policy_document" "jenkins_lambda_document" {
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
      "arn:aws:lambda:eu-west-2:328920706552:function:tdr-jenkins-sg-update-${var.environment}"
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
      "iam:UpdateAssumeRolePolicy"
    ]
    resources = [
      "arn:aws:iam::328920706552:instance-profile/jenkins_instance_profile_${var.environment}",
      "arn:aws:iam::328920706552:policy/api_ecs_execution_policy_${var.environment}",
      "arn:aws:iam::328920706552:policy/invoke-jenkins-sg-update-api-gateway_${var.environment}",
      "arn:aws:iam::328920706552:policy/jenkins_ec2_policy_${var.environment}",
      "arn:aws:iam::328920706552:policy/jenkins_fargate_policy_${var.environment}",
      "arn:aws:iam::328920706552:role/api_ecs_execution_role_${var.environment}",
      "arn:aws:iam::328920706552:role/api_ecs_task_role_${var.environment}",
      "arn:aws:iam::328920706552:role/aws-service-role/ecs.amazonaws.com/AWSServiceRoleForECS",
      "arn:aws:iam::328920706552:role/ecsExecutionRole",
      "arn:aws:iam::328920706552:role/ecsTaskRole",
      "arn:aws:iam::328920706552:role/jenkins_fargate_role_${var.environment}",
      "arn:aws:iam::328920706552:role/jenkins_lambda_role_${var.environment}",
      "arn:aws:iam::328920706552:role/jenkins-sg-update_lambda_role_${var.environment}"
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
      "arn:aws:elasticloadbalancing:eu-west-2:328920706552:listener/app/tdr-jenkins-load-balancer-${var.environment}/*/*",
      "arn:aws:elasticloadbalancing:eu-west-2:328920706552:listener/net/tdr-jenkins-load-balancer-${var.environment}/*/*",
      "arn:aws:elasticloadbalancing:eu-west-2:328920706552:loadbalancer/net/tdr-jenkins-load-balancer-${var.environment}/*",
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

resource "aws_iam_policy" "jenkins_cloudfront_policy" {
  policy = data.aws_iam_policy_document.jenkins_cloudfront_document.json
  name = "JenkinsCloudfront"
}

data "aws_iam_policy_document" "jenkins_cloudfront_document" {
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
      "arn:aws:cloudfront::328920706552:distribution/*"
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
      "arn:aws:ecs:eu-west-2:328920706552:cluster/jenkins-${var.environment}",
      "arn:aws:ecs:eu-west-2:328920706552:service/jenkins-${var.environment}/jenkins-service-${var.environment}"
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

resource "aws_iam_policy" "jenkins_ec2_policy" {
  policy = data.aws_iam_policy_document.jenkins_ec2_document.json
  name = "JenkinsEc2"
}


data "aws_iam_policy_document" "jenkins_ec2_document" {
  statement {
    actions   = [
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:CreateRoute",
      "ec2:DeleteSecurityGroup",
      "ec2:RevokeSecurityGroupEgress",
      "ec2:TerminateInstances"
    ]
    resources = [
      "arn:aws:ec2:eu-west-2:328920706552:instance/*",
      "arn:aws:ec2:eu-west-2:328920706552:route-table/*",
      "arn:aws:ec2:eu-west-2:328920706552:security-group/*",
      "arn:aws:ec2:eu-west-2:328920706552:vpc/*"
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
      "ec2:RunInstances"
    ]
    resources = ["*"]
  }
}



resource "aws_iam_group" "terraform_jenkins" {
  name = "terraform-jenkins"
}

resource "aws_iam_group_policy_attachment" "jenkins_ec2_attach" {
  group = aws_iam_group.terraform_jenkins.name
  policy_arn = aws_iam_policy.jenkins_ec2_policy.arn
}
resource "aws_iam_group_policy_attachment" "jenkins_ecs_attach" {
  group = aws_iam_group.terraform_jenkins.name
  policy_arn = aws_iam_policy.jenkins_ecs_policy.arn
}
resource "aws_iam_group_policy_attachment" "jenkins_cloudfront_attach" {
  group = aws_iam_group.terraform_jenkins.name
  policy_arn = aws_iam_policy.jenkins_cloudfront_policy.arn
}
resource "aws_iam_group_policy_attachment" "jenkins_elb_attach" {
  group = aws_iam_group.terraform_jenkins.name
  policy_arn = aws_iam_policy.jenkins_elb_policy.arn
}
resource "aws_iam_group_policy_attachment" "jenkins_iam_attach" {
  group = aws_iam_group.terraform_jenkins.name
  policy_arn = aws_iam_policy.jenkins_iam_policy.arn
}
resource "aws_iam_group_policy_attachment" "jenkins_lambda_attach" {
  group = aws_iam_group.terraform_jenkins.name
  policy_arn = aws_iam_policy.jenkins_lambda_policy.arn
}
resource "aws_iam_group_policy_attachment" "jenkins_ssm_attach" {
  group = aws_iam_group.terraform_jenkins.name
  policy_arn = aws_iam_policy.jenkins_ssm_policy.arn
}
resource "aws_iam_group_policy_attachment" "jenkins_logs_attach" {
  group = aws_iam_group.terraform_jenkins.name
  policy_arn = aws_iam_policy.jenkins_logs_policy.arn
}

