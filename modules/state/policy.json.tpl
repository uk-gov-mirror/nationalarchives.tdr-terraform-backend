{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::229554778675:role/TDRDbMigrationLambdaRoleIntg"
      },
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::tdr-database-migrations/*",
        "arn:aws:s3:::tdr-database-migrations"
      ]
    }
  ]
}