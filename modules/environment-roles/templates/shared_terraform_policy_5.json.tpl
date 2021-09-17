{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "cloudfront:CreateCloudFrontOriginAccessIdentity",
        "cloudfront:CreateKeyGroup",
        "cloudfront:CreateOriginRequestPolicy",
        "cloudfront:CreatePublicKey",
        "cloudfront:DeleteCachePolicy",
        "cloudfront:DeleteCloudFrontOriginAccessIdentity",
        "cloudfront:DeleteKeyGroup",
        "cloudfront:DeleteOriginRequestPolicy",
        "cloudfront:DeletePublicKey",
        "cloudfront:GetCachePolicy",
        "cloudfront:GetCloudFrontOriginAccessIdentity",
        "cloudfront:GetKeyGroup",
        "cloudfront:GetOriginRequestPolicy",
        "cloudfront:GetPublicKey",
        "cloudfront:ListCachePolicies",
        "cloudfront:ListKeyGroups",
        "cloudfront:ListPublicKeys",
        "cloudfront:ListTagsForResource",
        "cloudfront:UpdateCachePolicy",
        "cloudfront:UpdateCloudFrontOriginAccessIdentity",
        "cloudfront:UpdateKeyGroup",
        "cloudfront:UpdateOriginRequestPolicy",
        "cloudfront:UpdatePublicKey",
        "ec2:CreateNetworkAcl",
        "ec2:ReplaceNetworkAclAssociation",
        "ec2:CreateNetworkAclEntry",
        "ec2:ReplaceNetworkAclEntry",
        "ec2:DeleteNetworkAclEntry",
        "cloudfront:CreateCachePolicy"
      ],
      "Resource": ["*"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "cloudfront:CreateDistribution",
        "cloudfront:DeleteDistribution",
        "cloudfront:GetDistribution",
        "cloudfront:TagResource",
        "cloudfront:UpdateDistribution"
      ],
      "Resource": [
        "arn:aws:cloudfront::${account_id}:distribution/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ssm:GetParameter"
      ],
      "Resource": [
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/${environment_lower_case}/cloudfront/key/private"
      ]
    },
    {
      "Sid": "states",
      "Effect": "Allow",
      "Action" : [
        "states:CreateStateMachine",
        "states:UpdateStateMachine",
        "states:DeleteStateMachine",
        "states:TagResource",
        "states:UntagResource",
        "states:DescribeStateMachine",
        "states:ListTagsForResource"
      ],
      "Resource": [
        "arn:aws:states:eu-west-2:${account_id}:stateMachine:TDRConsignmentExport${environment}"
      ]
    }
  ]
}
