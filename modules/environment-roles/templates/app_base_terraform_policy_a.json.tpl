{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ecs",
      "Effect": "Allow",
      "Action": [
        "ecs:CreateService",
        "ecs:DeleteCluster",
        "ecs:DeleteService",
        "ecs:DescribeServices",
        "ecs:UpdateService",
        "ecs:DescribeClusters"
      ],
      "Resource": [
        "arn:aws:ecs:eu-west-2:${account_id}:cluster/${app_name}_${environment}",
        "arn:aws:ecs:eu-west-2:${account_id}:cluster/${app_name}-ecs-${environment}",
        "arn:aws:ecs:eu-west-2:${account_id}:service/${app_name}-ecs-${environment}/${app_name}-service-${environment}",
        "arn:aws:ecs:eu-west-2:${account_id}:service/${app_name}_${environment}/${app_name}_service_${environment}"
      ]
    },
    {
      "Sid": "ecsglobal",
      "Effect": "Allow",
      "Action": [
        "ecs:CreateCluster",
        "ecs:DeregisterTaskDefinition",
        "ecs:DescribeTaskDefinition",
        "ecs:RegisterTaskDefinition"
      ],
      "Resource": "*"
    },
    {
      "Sid": "elb",
      "Effect": "Allow",
      "Action": [
        "elasticloadbalancing:AddTags",
        "elasticloadbalancing:CreateListener",
        "elasticloadbalancing:CreateLoadBalancer",
        "elasticloadbalancing:DeleteListener",
        "elasticloadbalancing:DeleteLoadBalancer",
        "elasticloadbalancing:DeleteTargetGroup",
        "elasticloadbalancing:DeregisterTargets",
        "elasticloadbalancing:ModifyLoadBalancerAttributes",
        "elasticloadbalancing:ModifyTargetGroupAttributes",
        "elasticloadbalancing:RegisterTargets",
        "elasticloadbalancing:ModifyTargetGroup",
        "elasticloadbalancing:SetSecurityGroups"
      ],
      "Resource": [
        "arn:aws:elasticloadbalancing:eu-west-2:${account_id}:listener/app/tdr-${app_name}-load-balancer-${environment}/*/*",
        "arn:aws:elasticloadbalancing:eu-west-2:${account_id}:listener/net/tdr-${app_name}_load-balancer-${environment}/*/*",
        "arn:aws:elasticloadbalancing:eu-west-2:${account_id}:loadbalancer/net/tdr-${app_name}-load-balancer-${environment}/*",
        "arn:aws:elasticloadbalancing:eu-west-2:${account_id}:loadbalancer/app/tdr-${app_name}-load-balancer-${environment}/*",
        "arn:aws:elasticloadbalancing:eu-west-2:${account_id}:targetgroup/*"
      ]
    },
    {
      "Sid": "elbglobal",
      "Effect": "Allow",
      "Action": [
        "elasticloadbalancing:CreateTargetGroup",
        "elasticloadbalancing:DescribeListeners",
        "elasticloadbalancing:DescribeLoadBalancerAttributes",
        "elasticloadbalancing:DescribeLoadBalancers",
        "elasticloadbalancing:DescribeTags",
        "elasticloadbalancing:DescribeTargetGroupAttributes",
        "elasticloadbalancing:DescribeTargetGroups",
        "elasticloadbalancing:DescribeTargetHealth"
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Sid": "iam",
      "Effect": "Allow",
      "Action": [
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
        "iam:CreateServiceLinkedRole"
      ],
      "Resource": [
        "arn:aws:iam::${account_id}:policy/${app_name}_ecs_execution_policy_${environment}",
        "arn:aws:iam::${account_id}:policy/${app_name}_ecs_task_policy_${environment}",
        "arn:aws:iam::${account_id}:role/${app_name}_ecs_execution_role_${environment}",
        "arn:aws:iam::${account_id}:role/${app_name}_ecs_task_role_${environment}",
        "arn:aws:iam::${account_id}:role/aws-service-role/ecs.amazonaws.com/AWSServiceRoleForECS",
        "arn:aws:iam::${account_id}:role/aws-service-role/elasticloadbalancing.amazonaws.com/AWSServiceRoleForElasticLoadBalancing"

      ]
    },
    {
      "Sid": "iamglobal",
      "Effect": "Allow",
      "Action": [
        "iam:DeleteInstanceProfile",
        "iam:RemoveRoleFromInstanceProfile"
      ],
      "Resource": ["*"]
    },
    {
      "Sid": "lambda",
      "Effect": "Allow",
      "Action": [
        "lambda:AddPermission",
        "lambda:CreateFunction",
        "lambda:DeleteFunction",
        "lambda:GetFunction",
        "lambda:GetPolicy",
        "lambda:ListVersionsByFunction",
        "lambda:RemovePermission"
      ],
      "Resource": "arn:aws:lambda:eu-west-2:${account_id}:function:${app_name}_${environment}"
    },
    {
      "Sid": "acm",
      "Effect": "Allow",
      "Action" : [
        "acm:ListCertificates"
      ],
      "Resource": "*"
    }
  ]
}