{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": [
        "rds:RestoreDBClusterToPointInTime",
        "iam:GetRole",
        "ssm:GetParameter",
        "ssm:GetParameters",
        "ssm:ListTagsForResource",
        "rds:ListTagsForResource",
        "rds:AddTagsToResource",
        "rds:DescribeDBClusters",
        "rds:DescribeDBSubnetGroups",
        "rds:ModifyDBCluster",
        "ssm:PutParameter",
        "iam:CreatePolicy"
      ],
      "Resource": [
        "arn:aws:rds:eu-west-2:${account_id}:cluster:*",
        "arn:aws:iam::${account_id}:role/consignmentapi_ecs_task_role_${environment}",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/mgmt/cost_centre",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/${environment}/consignmentapi/database/url",
        "arn:aws:rds:eu-west-2:${account_id}:subgrp:*",
        "arn:aws:iam::${account_id}:policy/RestoredDbAccessPolicy$${environment}"
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
