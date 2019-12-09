{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ssm",
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
      "Resource": "arn:aws:logs:eu-west-2:328920706552:log-group:*"
    },
    {
      "Sid": "ssm_global",
      "Effect": "Allow",
      "Action": [
        "logs:DescribeLogGroups"
      ],
      "Resource": "*"
    }
  ]
}