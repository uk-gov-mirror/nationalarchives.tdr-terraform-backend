{
  "Version": "2012-10-17",
  "Statement": [
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
        "iam:DeleteRolePolicy",
        "iam:DetachRolePolicy",
        "iam:GetPolicy",
        "iam:GetPolicyVersion",
        "iam:GetRole",
        "iam:ListAttachedRolePolicies",
        "iam:ListInstanceProfilesForRole",
        "iam:ListPolicyVersions",
        "iam:PassRole",
        "iam:PutRolePolicy",
        "iam:TagRole",
        "iam:UpdateAssumeRolePolicy",
        "iam:UpdateRole",
        "iam:CreateServiceLinkedRole",
        "iam:CreatePolicyVersion",
        "iam:CreateOpenIDConnectProvider",
        "iam:GetOpenIDConnectProvider",
        "iam:DeleteOpenIDConnectProvider"
      ],
      "Resource": [
        "arn:aws:iam::${account_id}:role/aws-service-role/guardduty.amazonaws.com/AWSServiceRoleForAmazonGuardDuty",
        "arn:aws:iam::${account_id}:role/aws-service-role/ecs.amazonaws.com/AWSServiceRoleForECS",
        "arn:aws:iam::${account_id}:role/aws-service-role/elasticloadbalancing.amazonaws.com/AWSServiceRoleForElasticLoadBalancing",
        "arn:aws:iam::${account_id}:role/aws-service-role/rds.amazonaws.com/AWSServiceRoleForRDS",
        "arn:aws:iam::${account_id}:role/aws-service-role/ecs.amazonaws.com/AWSServiceRoleForECS",
        "arn:aws:iam::${account_id}:role/aws-service-role/elasticache.amazonaws.com/AWSServiceRoleForElastiCache*",
        "arn:aws:iam::${account_id}:policy/TDRCloudwatch${environment}",
        "arn:aws:iam::${account_id}:role/TDRCloudTrail${environment}",
        "arn:aws:iam::${account_id}:oidc-provider/auth.${sub_domain}.nationalarchives.gov.uk",
        "arn:aws:iam::${account_id}:oidc-provider/auth.${sub_domain}.nationalarchives.gov.uk/auth/realms/tdr",
        "arn:aws:iam::${account_id}:policy/TDRDbMigrationLambdaPolicy${environment}",
        "arn:aws:iam::${account_id}:role/TDRDbMigrationLambdaRole${environment}",
        "arn:aws:iam::${account_id}:policy/TDRConfig${environment}",
        "arn:aws:iam::${account_id}:role/TDRConfig${environment}",
        "arn:aws:iam::${account_id}:policy/TDRSNSPublish${environment}",
        "arn:aws:iam::${account_id}:role/Custodian*",
        "arn:aws:iam::${account_id}:policy/TDRCustodian*",
        "arn:aws:iam::${account_id}:role/TDRCognitoAuthorisedRole${environment}",
        "arn:aws:iam::${account_id}:policy/CognitoAuthPolicy${environment}",
        "arn:aws:iam::${account_id}:policy/TDRYaraAvPolicy",
        "arn:aws:iam::${account_id}:policy/TDRChecksumPolicy",
        "arn:aws:iam::${account_id}:role/TDRChecksumRole",
        "arn:aws:iam::${account_id}:role/TDRYaraAvRole",
        "arn:aws:iam::${account_id}:policy/TDRLogDataLambdaBase${environment}",
        "arn:aws:iam::${account_id}:policy/TDRLogData${environment}",
        "arn:aws:iam::${account_id}:role/TDRLogDataAssumeRole${environment}",
        "arn:aws:iam::${account_id}:role/TDRLogDataCrossAccountRoleMgmt",
        "arn:aws:iam::${account_id}:policy/TDRApiUpdatePolicy",
        "arn:aws:iam::${account_id}:role/TDRApiUpdateRole",
        "arn:aws:iam::${account_id}:role/TDRFileFormatEcsTaskRole${environment}",
        "arn:aws:iam::${account_id}:role/TDRFileFormatECSExecutionRole${environment}",
        "arn:aws:iam::${account_id}:role/TDRFileFormatRole${environment}",
        "arn:aws:iam::${account_id}:policy/TDRFileFormatLambdaPolicy${environment}",
        "arn:aws:iam::${account_id}:policy/TDRFileFormatECSTaskPolicy${environment}",
        "arn:aws:iam::${account_id}:policy/TDRFileFormatECSExecutionPolicy${environment}",
        "arn:aws:iam::${account_id}:policy/TDRDownloadFilesPolicy",
        "arn:aws:iam::${account_id}:role/TDRDownloadFilesRole",
        "arn:aws:iam::${account_id}:role/TDRExportAPIRole${environment}",
        "arn:aws:iam::${account_id}:role/TDRExportAPICloudwatchRole${environment}",
        "arn:aws:iam::${account_id}:policy/TDRExportAPIPolicy${environment}",
        "arn:aws:iam::${account_id}:policy/TDRExportAPICloudwatchPolicy${environment}",
        "arn:aws:iam::${account_id}:policy/TDRConsignmentExportECSTaskPolicy${environment}",
        "arn:aws:iam::${account_id}:policy/TDRConsignmentExportECSExecutionPolicy${environment}",
        "arn:aws:iam::${account_id}:role/TDRExportApiAuthoriserLambdaRole${environment}",
        "arn:aws:iam::${account_id}:policy/TDRExportApiAuthoriserLambdaPolicy${environment}",
        "arn:aws:iam::${account_id}:role/TDRConsignmentExportECSExecutionRole${environment}",
        "arn:aws:iam::${account_id}:role/TDRConsignmentExportEcsTaskRole${environment}",
        "arn:aws:iam::${account_id}:role/TDRConsignmentExportRole${environment}",
        "arn:aws:iam::${account_id}:policy/TDRConsignmentExportPolicy${environment}",
        "arn:aws:iam::${account_id}:policy/TDRCreateDbUsersPolicy${environment}",
        "arn:aws:iam::${account_id}:role/TDRCreateDbUsersRole${environment}",
        "arn:aws:iam::${account_id}:policy/TDRConsignmentApiAllowIAMAuthPolicy${environment}"
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
