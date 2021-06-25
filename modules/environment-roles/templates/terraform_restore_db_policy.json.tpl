{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": [
        "iam:AttachRolePolicy",
        "iam:CreatePolicy",
        "iam:CreatePolicyVersion",
        "iam:DeletePolicy",
        "iam:DeletePolicyVersion",
        "iam:DetachRolePolicy",
        "iam:GetPolicy",
        "iam:GetPolicyVersion",
        "iam:GetRole",
        "iam:ListAttachedRolePolicies",
        "iam:ListPolicyVersions",
        "rds:AddTagsToResource",
        "rds:CreateDBInstance",
        "rds:DeleteDBCluster",
        "rds:DeleteDBInstance",
        "rds:DescribeDBClusters",
        "rds:DescribeDBInstances",
        "rds:DescribeDBSubnetGroups",
        "rds:ListTagsForResource",
        "rds:ModifyDBCluster",
        "rds:RestoreDBClusterToPointInTime",
        "ssm:GetParameter",
        "ssm:GetParameters",
        "ssm:ListTagsForResource",
        "ssm:PutParameter"
      ],
      "Resource": [
        "arn:aws:iam::${account_id}:policy/RestoredDbAccessPolicy${title_environment}",
        "arn:aws:iam::${account_id}:role/consignmentapi_ecs_task_role_${environment}",
        "arn:aws:iam::${account_id}:role/keycloak_ecs_task_role_${environment}",
        "arn:aws:rds:eu-west-2:${account_id}:cluster:restored-db",
        "arn:aws:rds:eu-west-2:${account_id}:db:restored-db",
        "arn:aws:rds:eu-west-2:${account_id}:subgrp:*",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/${environment}/consignmentapi/database/url",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/${environment}/keycloak/database/url",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/mgmt/cost_centre"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeSecurityGroups",
        "kms:CreateGrant",
        "kms:DescribeKey",
        "rds:DescribeGlobalClusters"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ssm:DescribeParameters"
      ],
      "Resource": [
        "arn:aws:ssm:eu-west-2:${account_id}:*"
      ]
    }
  ]
}
