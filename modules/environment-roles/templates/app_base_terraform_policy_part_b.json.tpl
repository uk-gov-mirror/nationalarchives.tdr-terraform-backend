{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "cloudfront",
      "Effect": "Allow",
      "Action": [
        "cloudfront:CreateDistribution",
        "cloudfront:CreateDistributionWithTags",
        "cloudfront:DeleteDistribution",
        "cloudfront:GetDistribution",
        "cloudfront:ListTagsForResource",
        "cloudfront:TagResource",
        "cloudfront:UpdateDistribution"
      ],
      "Resource": "arn:aws:cloudfront::${account_id}:distribution/*"
    },
    {
      "Sid": "cloudwatch",
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogStream",
        "logs:DeleteLogGroup",
        "logs:DeleteLogStream",
        "logs:DescribeLogStreams",
        "logs:CreateLogGroup",
        "logs:PutRetentionPolicy",
        "logs:ListTagsLogGroup"
      ],
      "Resource": "arn:aws:logs:eu-west-2:${account_id}:log-group:*"
    },
    {
      "Sid": "cloudwatchglobal",
      "Effect": "Allow",
      "Action": [
        "logs:DescribeLogGroups"
      ],
      "Resource": "*"
    },
    {
      "Sid": "ec2",
      "Effect": "Allow",
      "Action": [
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:CreateRoute",
        "ec2:DeleteSecurityGroup",
        "ec2:RevokeSecurityGroupEgress",
        "ec2:RevokeSecurityGroupIngress",
        "ec2:TerminateInstances"
      ],
      "Resource": [
        "arn:aws:ec2:eu-west-2:${account_id}:instance/*",
        "arn:aws:ec2:eu-west-2:${account_id}:route-table/*",
        "arn:aws:ec2:eu-west-2:${account_id}:security-group/*",
        "arn:aws:ec2:eu-west-2:${account_id}:vpc/*"
      ]
    },
    {
      "Sid": "ec2global",
      "Effect": "Allow",
      "Action": [
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
        "ec2:DescribeAccountAttributes"
      ],
      "Resource": "*"
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
        "rds:ModifyDBCluster"
      ],
      "Resource": [
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
    },
    {
      "Sid": "ssmglobal",
      "Effect": "Allow",
      "Action" : [
        "ssm:DescribeParameters"
      ],
      "Resource": "arn:aws:ssm:eu-west-2:${account_id}:*"
    }
  ]
}