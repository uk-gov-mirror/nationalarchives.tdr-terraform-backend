{
  "Version": "2012-10-17",

  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": [
        "sts:AssumeRole",
        "s3:PutObject",
        "s3:ListBucket",
        "s3:GetObject"
      ],
      "Resource": [
        "arn:aws:iam::${account_number}:role/TDRJenkinsLambdaRole${stage}",
        "arn:aws:s3:::tdr-releases-mgmt/*",
        "arn:aws:s3:::tdr-releases-mgmt"
      ]
    }
  ]
}