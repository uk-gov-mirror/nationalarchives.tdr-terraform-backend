{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "acm",
      "Effect": "Allow",
      "Action" : [
        "acm:ListCertificates",
        "acm:ListCertificates",
        "acm:DescribeCertificate",
        "elasticloadbalancing:CreateTargetGroup",
        "elasticloadbalancing:DescribeListeners",
        "elasticloadbalancing:DescribeLoadBalancerAttributes",
        "elasticloadbalancing:DescribeLoadBalancers",
        "elasticloadbalancing:DescribeTags",
        "elasticloadbalancing:DescribeTargetGroupAttributes",
        "elasticloadbalancing:DescribeTargetGroups",
        "elasticloadbalancing:DescribeTargetHealth",
        "ecs:CreateCluster",
        "ecs:DeregisterTaskDefinition",
        "ecs:DescribeTaskDefinition",
        "ecs:RegisterTaskDefinition",
        "ec2:AllocateAddress",
        "ec2:AssociateRouteTable",
        "ec2:AttachInternetGateway",
        "ec2:AuthorizeSecurityGroupEgress",
        "ec2:CreateFlowLogs",
        "ec2:CreateInternetGateway",
        "ec2:CreateNatGateway",
        "ec2:CreateNetworkInterface",
        "ec2:CreateRouteTable",
        "ec2:CreateSecurityGroup",
        "ec2:CreateSubnet",
        "ec2:CreateTags",
        "ec2:CreateVpc",
        "ec2:DeleteFlowLogs",
        "ec2:DeleteInternetGateway",
        "ec2:DeleteKeyPair",
        "ec2:DeleteNatGateway",
        "ec2:DeleteNetworkInterface",
        "ec2:DeleteRoute",
        "ec2:DeleteRouteTable",
        "ec2:DeleteSubnet",
        "ec2:DeleteVpc",
        "ec2:DescribeAddresses",
        "ec2:DescribeFlowLogs",
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
        "ec2:DescribeAccountAttributes",
        "iam:DeleteAccountPasswordPolicy",
        "iam:DeleteInstanceProfile",
        "iam:GetAccountPasswordPolicy",
        "iam:RemoveRoleFromInstanceProfile",
        "iam:UpdateAccountPasswordPolicy",
        "logs:DescribeLogGroups",
        "route53:ListHostedZones",
        "route53:GetHostedZone",
        "route53:ChangeResourceRecordSets",
        "route53:GetChange",
        "route53:ListResourceRecordSets",
        "route53:ListTagsForResource"
      ],
      "Resource": "*"
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
        "logs:ListTagsLogGroup",
        "logs:TagLogGroup"
      ],
      "Resource": "arn:aws:logs:eu-west-2:${account_id}:log-group:*"
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
      "Sid": "ssmglobal",
      "Effect": "Allow",
      "Action" : [
        "ssm:DescribeParameters"
      ],
      "Resource": "arn:aws:ssm:eu-west-2:${account_id}:*"
    },
    {
      "Sid" : "ssm",
      "Effect": "Allow",
      "Action": [
          "ssm:GetParameter"
      ],
      "Resource" : [
          "arn:aws:ssm:eu-west-2:${account_id}:parameter/mgmt/cost_centre"
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
        "iam:CreateServiceLinkedRole",
        "iam:CreatePolicyVersion"
      ],
      "Resource": [
        "arn:aws:iam::${account_id}:role/aws-service-role/ecs.amazonaws.com/AWSServiceRoleForECS",
        "arn:aws:iam::${account_id}:role/aws-service-role/elasticloadbalancing.amazonaws.com/AWSServiceRoleForElasticLoadBalancing",
        "arn:aws:iam::${account_id}:role/aws-service-role/rds.amazonaws.com/AWSServiceRoleForRDS",
        "arn:aws:iam::${account_id}:role/aws-service-role/ecs.amazonaws.com/AWSServiceRoleForECS",
        "arn:aws:iam::${account_id}:role/aws-service-role/elasticache.amazonaws.com/AWSServiceRoleForElastiCache*",
        "arn:aws:iam::${account_id}:policy/TDRDbMigrationLambdaPolicy${environment}",
        "arn:aws:iam::${account_id}:role/TDRDbMigrationLambdaRole${environment}"

      ]
    },
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
    }
  ]
}
