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
        "ecs:DescribeClusters",
        "ecs:TagResource"
      ],
      "Resource": [
        "arn:aws:ecs:eu-west-2:${account_id}:cluster/${app_name}_${environment}",
        "arn:aws:ecs:eu-west-2:${account_id}:cluster/${app_name}-ecs-${environment}",
        "arn:aws:ecs:eu-west-2:${account_id}:service/${app_name}-ecs-${environment}/${app_name}-service-${environment}",
        "arn:aws:ecs:eu-west-2:${account_id}:service/${app_name}_${environment}/${app_name}_service_${environment}",
        "arn:aws:ecs:eu-west-2:${account_id}:task-definition/${app_name}-${environment}:*"
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
        "elasticloadbalancing:ModifyListener",
        "elasticloadbalancing:ModifyLoadBalancerAttributes",
        "elasticloadbalancing:ModifyTargetGroupAttributes",
        "elasticloadbalancing:RegisterTargets",
        "elasticloadbalancing:ModifyTargetGroup",
        "elasticloadbalancing:SetSecurityGroups",
        "elasticloadbalancing:SetWebACL"
      ],
      "Resource": [
        "arn:aws:elasticloadbalancing:eu-west-2:${account_id}:listener/app/tdr-${app_name}-${environment}/*/*",
        "arn:aws:elasticloadbalancing:eu-west-2:${account_id}:listener/net/tdr-${app_name}-${environment}/*/*",
        "arn:aws:elasticloadbalancing:eu-west-2:${account_id}:loadbalancer/net/tdr-${app_name}-${environment}/*",
        "arn:aws:elasticloadbalancing:eu-west-2:${account_id}:loadbalancer/app/tdr-${app_name}-${environment}/*",
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
        "iam:DeletePolicyVersion",
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
        "iam:CreateServiceLinkedRole",
        "iam:CreatePolicyVersion"
      ],
      "Resource": [
        "arn:aws:iam::${account_id}:policy/${app_name}_ecs_execution_policy_${environment}",
        "arn:aws:iam::${account_id}:policy/${app_name}_ecs_task_policy_${environment}",
        "arn:aws:iam::${account_id}:policy/TDRKeycloakFlowlogPolicy${title(environment)}",
        "arn:aws:iam::${account_id}:policy/TDRVpcFlowlogPolicy${title(environment)}",
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
        "lambda:CreateEventSourceMapping",
        "lambda:CreateFunction",
        "lambda:DeleteEventSourceMapping",
        "lambda:DeleteFunction",
        "lambda:DeleteFunctionEventInvokeConfig",
        "lambda:GetAlias",
        "lambda:GetEventSourceMapping",
        "lambda:GetFunction",
        "lambda:GetFunctionConcurrency",
        "lambda:GetFunctionConfiguration",
        "lambda:GetFunctionEventInvokeConfig",
        "lambda:GetLayerVersion",
        "lambda:GetLayerVersionPolicy",
        "lambda:GetPolicy",
        "lambda:ListVersionsByFunction",
        "lambda:ListTags",
        "lambda:RemovePermission",
        "lambda:TagResource",
        "lambda:UpdateFunctionConfiguration",
        "lambda:PutFunctionEventInvokeConfig",
        "lambda:UpdateEventSourceMapping",
        "lambda:UpdateFunctionCode"
      ],
      "Resource": [
        "arn:aws:lambda:eu-west-2:${account_id}:function:${app_name}_${environment}",
        "arn:aws:lambda:eu-west-2:${account_id}:function:tdr-database-migrations-${environment}",
        "arn:aws:lambda:eu-west-2:${account_id}:function:tdr-checksum-${environment}",
        "arn:aws:lambda:eu-west-2:${account_id}:function:tdr-yara-av-${environment}",
        "arn:aws:lambda:eu-west-2:${account_id}:function:tdr-api-update-${environment}",
        "arn:aws:lambda:eu-west-2:${account_id}:function:tdr-file-format-${environment}",
        "arn:aws:lambda:eu-west-2:${account_id}:function:tdr-download-files-${environment}",
        "arn:aws:lambda:eu-west-2:${account_id}:function:tdr-export-api-authoriser-${environment}",
        "arn:aws:lambda:eu-west-2:${account_id}:function:tdr-create-db-users-${environment}",
        "arn:aws:lambda:eu-west-2:${account_id}:event-source-mapping:*"
      ]
    },
    {
      "Sid": "storage",
      "Effect": "Allow",
      "Action": [
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
      "Sid": "ssm",
      "Effect": "Allow",
      "Action": [
        "ssm:AddTagsToResource",
        "ssm:DeleteParameter",
        "ssm:GetParameter",
        "ssm:GetParameters",
        "ssm:ListTagsForResource",
        "ssm:PutParameter"
      ],
      "Resource": [
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/${environment}/${app_name}/database/url",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/${environment}/${app_name}/database/username",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/${environment}/${app_name}/database/password",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/${environment}/${app_name}/database/api/password",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/${environment}/${app_name}/database/migrations/password",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/${environment}/${app_name}/admin/password",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/${environment}/${app_name}/admin/user",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/${environment}/${app_name}/client/secret",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/${environment}/${app_name}/backend_checks_client/secret",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/${environment}/${app_name}/realm_admin_client/secret",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/${environment}/${app_name}/configuration_properties",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/${environment}/${app_name}/user_admin_client/secret",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/${environment}/${app_name}/govuk_notify/template_id",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/${environment}/${app_name}/govuk_notify/api_key"
      ]
    }
  ]
}
