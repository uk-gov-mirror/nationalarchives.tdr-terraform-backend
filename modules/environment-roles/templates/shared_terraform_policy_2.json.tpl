{
  "Version": "2012-10-17",
  "Statement": [
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
      "Sid" : "kms",
      "Effect": "Allow",
      "Action" : [
        "kms:CreateAlias",
        "kms:CreateKey",
        "kms:CreateGrant",
        "kms:Decrypt",
        "kms:DeleteAlias",
        "kms:DeleteKey",
        "kms:DescribeKey",
        "kms:EnableKey",
        "kms:EnableKeyRotation",
        "kms:Encrypt",
        "kms:GetKeyPolicy",
        "kms:GetKeyRotationStatus",
        "kms:ListAliases",
        "kms:ListGrants",
        "kms:ListKeyPolicies",
        "kms:ListKeys",
        "kms:ListResourceTags",
        "kms:ListRetirableGrants",
        "kms:PutKeyPolicy",
        "kms:RevokeGrant",
        "kms:ScheduleKeyDeletion",
        "kms:TagResource",
        "kms:UntagResource",
        "kms:UpdateAlias",
        "kms:UpdateKeyDescription"
      ],
      "Resource": "*"
    },
    {
      "Sid": "s3",
      "Effect": "Allow",
      "Action": [
        "s3:CreateBucket",
        "s3:DeleteBucket",
        "s3:DeleteBucketPolicy",
        "s3:GetAccelerateConfiguration",
        "s3:GetAccountPublicAccessBlock",
        "s3:GetBucketAcl",
        "s3:GetBucketCORS",
        "s3:GetBucketLocation",
        "s3:GetBucketLogging",
        "s3:GetBucketNotification",
        "s3:GetBucketObjectLockConfiguration",
        "s3:GetBucketPolicy",
        "s3:GetBucketPolicyStatus",
        "s3:GetBucketPublicAccessBlock",
        "s3:GetBucketRequestPayment",
        "s3:GetBucketTagging",
        "s3:GetBucketVersioning",
        "s3:GetBucketWebsite",
        "s3:GetEncryptionConfiguration",
        "s3:GetInventoryConfiguration",
        "s3:GetLifecycleConfiguration",
        "s3:GetMetricsConfiguration",
        "s3:GetReplicationConfiguration",
        "s3:ListBucket",
        "s3:PutBucketLogging",
        "s3:PutBucketAcl",
        "S3:PutBucketCORS",
        "s3:PutBucketPolicy",
        "s3:PutBucketPublicAccessBlock",
        "s3:PutBucketTagging",
        "s3:PutBucketVersioning",
        "s3:PutBucketWebsite",
        "s3:PutEncryptionConfiguration"
      ],
      "Resource": "*"
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
