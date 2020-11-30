{
  "Version": "2012-10-17",

  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": [
        "sts:AssumeRole",
        "s3:GetObject",
        "s3:ListBucket",
        "s3:PutObject"
      ],
      "Resource": [
        "arn:aws:iam::${account_number}:role/TDRJenkinsS3ExportRole${env_title_case}",
        "arn:aws:s3:::tdr-releases-mgmt/*",
        "arn:aws:s3:::tdr-releases-mgmt"
      ]
    }
  ]
}
