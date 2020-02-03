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
        "arn:aws:elasticloadbalancing:eu-west-2:${account_id}:listener/app/tdr-${app_name}-lb-${environment}/*/*",
        "arn:aws:elasticloadbalancing:eu-west-2:${account_id}:listener/net/tdr-${app_name}_lb-${environment}/*/*",
        "arn:aws:elasticloadbalancing:eu-west-2:${account_id}:loadbalancer/net/tdr-${app_name}-lb-${environment}/*",
        "arn:aws:elasticloadbalancing:eu-west-2:${account_id}:loadbalancer/app/tdr-${app_name}-lb-${environment}/*",
        "arn:aws:elasticloadbalancing:eu-west-2:${account_id}:targetgroup/*"
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
        "arn:aws:iam::${account_id}:policy/keycloak_flowlog_policy_${environment}",
        "arn:aws:iam::${account_id}:policy/tdr_flowlog_policy_${environment}",
        "arn:aws:iam::${account_id}:role/${app_name}_ecs_execution_role_${environment}",
        "arn:aws:iam::${account_id}:role/${app_name}_ecs_task_role_${environment}",
        "arn:aws:iam::${account_id}:role/keycloak_flowlog_role_${environment}",
        "arn:aws:iam::${account_id}:role/tdr_flowlog_role_${environment}"
      ]
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
        "lambda:RemovePermission",
        "lambda:UpdateFunctionConfiguration"
      ],
      "Resource": [
        "arn:aws:lambda:eu-west-2:${account_id}:function:${app_name}_${environment}",
        "arn:aws:lambda:eu-west-2:${account_id}:function:tdr-database-migrations-${environment}"
      ]
    },
    {
      "Sid" : "storage",
      "Effect": "Allow",
      "Action" : [
        "rds:DescribeDBSubnetGroups",
        "rds:CreateDBSubnetGroup",
        "rds:DeleteDBSubnetGroup",
        "rds:ModifyDBSubnetGroup",
        "rds:CreateDBCluster",
        "rds:AddTagsToResource",
        "rds:DescribeDBClusters",
        "rds:ListTagsForResource",
        "rds:DeleteDBCluster",
        "rds:ModifyDBCluster",
        "rds:CreateDBInstance",
        "rds:DeleteDBInstance",
        "rds:DescribeDBInstances"
      ],
      "Resource": [
        "arn:aws:rds:eu-west-2:${account_id}:db:*",
        "arn:aws:rds:eu-west-2:${account_id}:subgrp:main-${environment}",
        "arn:aws:rds:eu-west-2:${account_id}:subgrp:tdr-${environment}",
        "arn:aws:rds:eu-west-2:${account_id}:cluster:*"
      ]
    },
    {
      "Sid" : "ssm",
      "Effect": "Allow",
      "Action": [
        "ssm:AddTagsToResource",
        "ssm:DeleteParameter",
        "ssm:GetParameter",
        "ssm:GetParameters",
        "ssm:ListTagsForResource",
        "ssm:PutParameter"
      ],
      "Resource" : [
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/${environment}/${app_name}/database/url",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/${environment}/${app_name}/database/username",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/${environment}/${app_name}/database/password",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/${environment}/${app_name}/admin/password",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/${environment}/${app_name}/admin/user"
      ]
    }
  ]
}