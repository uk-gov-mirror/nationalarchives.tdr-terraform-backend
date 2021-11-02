{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": [
        "ecs:RunTask",
        "iam:PassRole",
        "lambda:GetFunctionConfiguration",
        "lambda:InvokeFunction",
        "lambda:UpdateEventSourceMapping",
        "lambda:UpdateFunctionCode",
        "lambda:PublishVersion",
        "s3:GetObject"
      ],
      "Resource": [
        "arn:aws:s3:::tdr-backend-code-mgmt/*",
        "arn:aws:lambda:eu-west-2:${account_id}:function:tdr-yara-av-${environment}",
        "arn:aws:lambda:eu-west-2:${account_id}:function:tdr-sign-cookies-${environment}",
        "arn:aws:lambda:eu-west-2:${account_id}:function:tdr-service-unavailable-${environment}",
        "arn:aws:lambda:eu-west-2:${account_id}:function:tdr-notifications-${environment}",
        "arn:aws:lambda:eu-west-2:${account_id}:function:tdr-file-format-${environment}",
        "arn:aws:lambda:eu-west-2:${account_id}:function:tdr-export-api-authoriser-${environment}",
        "arn:aws:lambda:eu-west-2:${account_id}:function:tdr-download-files-${environment}",
        "arn:aws:lambda:eu-west-2:${account_id}:function:tdr-database-migrations-${environment}",
        "arn:aws:lambda:eu-west-2:${account_id}:function:tdr-create-keycloak-db-user-${environment}",
        "arn:aws:lambda:eu-west-2:${account_id}:function:tdr-create-db-users-${environment}",
        "arn:aws:lambda:eu-west-2:${account_id}:function:tdr-create-bastion-user-${environment}",
        "arn:aws:lambda:eu-west-2:${account_id}:function:tdr-checksum-${environment}",
        "arn:aws:lambda:eu-west-2:${account_id}:function:tdr-api-update-${environment}",
        "arn:aws:lambda:eu-west-2:${account_id}:event-source-mapping:*",
        "arn:aws:iam::${account_id}:role/file_format_ecs_execution_role_${environment}",
        "arn:aws:iam::${account_id}:role/TDRFileFormatEcsTaskRole${title_environment}",
        "arn:aws:iam::${account_id}:role/TDRFileFormatECSExecutionRole${title_environment}",
        "arn:aws:ecs:eu-west-2:${account_id}:task-definition/file-format-build-${environment}"
      ]
    },
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSubnets",
        "lambda:ListEventSourceMappings"
      ],
      "Resource": "*"
    }
  ]
}