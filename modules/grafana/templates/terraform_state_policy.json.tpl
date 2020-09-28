{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": "s3:ListBucket",
      "Resource": "${state_bucket_arn}"
    },
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": [
        "dynamodb:PutItem",
        "dynamodb:GetItem",
        "dynamodb:DeleteItem"
      ],
      "Resource": "${state_dynamo_db_arn}"
    },
    {
       "Sid": "",
       "Effect": "Allow",
       "Action": [
          "s3:PutObject",
          "s3:GetObject"
       ],
       "Resource": "${state_bucket_arn}/*"
    },
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeAvailabilityZones",
        "ec2:DescribeAccountAttributes"
      ],
      "Resource": "*"
    }
  ]
}
