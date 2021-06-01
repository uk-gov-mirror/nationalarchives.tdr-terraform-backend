{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ssmglobal",
      "Effect": "Allow",
      "Action": [
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
          "arn:aws:ssm:eu-west-2:${account_id}:parameter/mgmt/aws_elb_account",
          "arn:aws:ssm:eu-west-2:${account_id}:parameter/mgmt/cost_centre",
          "arn:aws:ssm:eu-west-2:${account_id}:parameter/mgmt/management_account"
      ]
    },
    {
      "Sid": "kms",
      "Effect": "Allow",
      "Action": [
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
        "s3:DeleteObject",
        "s3:DeleteObjectTagging",
        "s3:DeleteObjectVersion",
        "s3:DeleteObjectVersionTagging",
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
        "s3:GetObject",
        "s3:GetObjectTagging",
        "s3:GetObjectVersion",
        "s3:GetReplicationConfiguration",
        "s3:ListBucket",
        "s3:ListBucketVersions",
        "s3:ListObjectVersions",
        "s3:PutBucketLogging",
        "s3:PutBucketAcl",
        "S3:PutBucketCORS",
        "S3:PutBucketNotification",
        "s3:PutBucketPolicy",
        "s3:PutBucketPublicAccessBlock",
        "s3:PutBucketTagging",
        "s3:PutBucketVersioning",
        "s3:PutBucketWebsite",
        "s3:PutEncryptionConfiguration",
        "s3:PutLifecycleConfiguration",
        "s3:PutObject",
        "s3:PutObjectAcl",
        "s3:PutObjectTagging",
        "s3:PutObjectVersionTagging"
      ],
      "Resource": "*"
    },
    {
      "Sid": "ApiGatewayDeployment",
      "Effect": "Allow",
      "Action": [
        "apigateway:POST",
        "apigateway:PUT",
        "apigateway:GET",
        "apigateway:DELETE",
        "apigateway:PATCH"
      ],
      "Resource": "arn:aws:apigateway:eu-west-2::*"
    }
  ]
}
