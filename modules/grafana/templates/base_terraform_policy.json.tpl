{
  "Version": "2012-10-17",
  "Statement": [
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
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/${environment}/grafana/admin/password",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/${environment}/grafana/admin/user",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/${environment}/grafana/database/password",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/${environment}/grafana/database/url",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/${environment}/grafana/database/username",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/${environment}/intg_account",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/${environment}/prod_account",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/${environment}/staging_account"
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
        "iam:CreatePolicyVersion",
        "iam:CreateRole",
        "iam:CreateServiceLinkedRole",
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
      ],
      "Resource": [
        "arn:aws:iam::${account_id}:policy/TDRGrafanaEcsExecutionPolicy${title(environment)}",
        "arn:aws:iam::${account_id}:policy/TDRGrafanaEnvMonitoringAssumeRoles",
        "arn:aws:iam::${account_id}:policy/TDRGrafana${title(environment)}LogPermissions",
        "arn:aws:iam::${account_id}:role/TDRGrafanaAppExecutionRole${title(environment)}",
        "arn:aws:iam::${account_id}:role/TDRGrafanaAppTaskRole${title(environment)}"
      ]
    },
    {
      "Sid" : "storage",
      "Effect": "Allow",
      "Action" : [
        "rds:AddTagsToResource",
        "rds:CreateDBCluster",
        "rds:CreateDBInstance",
        "rds:CreateDBSubnetGroup",
        "rds:DeleteDBCluster",
        "rds:DeleteDBInstance",
        "rds:DeleteDBSubnetGroup",
        "rds:DescribeDBClusters",
        "rds:DescribeDBInstances",
        "rds:DescribeDBSubnetGroups",
        "rds:ListTagsForResource",
        "rds:ModifyDBCluster",
        "rds:ModifyDBSubnetGroup"
      ],
      "Resource": [
        "arn:aws:rds:eu-west-2:${account_id}:cluster:*",
        "arn:aws:rds:eu-west-2:${account_id}:db:*",
        "arn:aws:rds:eu-west-2:${account_id}:subgrp:main-mgmt",
        "arn:aws:rds:eu-west-2:${account_id}:subgrp:tdr-mgmt"
      ]
    }
  ]
}
