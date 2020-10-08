{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": [
        "lambda:UpdateFunctionCode",
        "lambda:PublishVersion",
        "s3:PutObject",
        "s3:GetObject"
      ],
      "Resource": [
        "arn:aws:lambda:eu-west-2:${account_id}:function:tdr-ecr-scan-notifications-${environment}",
        "arn:aws:s3:::tdr-backend-code-${environment}/*"
      ]
    }
  ]
}
