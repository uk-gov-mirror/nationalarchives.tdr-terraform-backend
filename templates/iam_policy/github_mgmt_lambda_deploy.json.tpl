{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": [
        "lambda:GetFunctionConfiguration",
        "lambda:PublishVersion",
        "lambda:UpdateFunctionCode",
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": [
        "arn:aws:lambda:eu-west-2:${account_id}:function:tdr-notifications-mgmt",
        "arn:aws:lambda:eu-west-2:${account_id}:function:tdr-ecr-scan-mgmt",
        "arn:aws:s3:::tdr-backend-code-mgmt/*"
      ]
    }
  ]
}
