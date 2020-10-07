{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": "lambda:UpdateFunctionCode",
      "Resource": "arn:aws:lambda:eu-west-2:${account_id}:function:tdr-ecr-scan-notifications-mgmt"
    }
  ]
}