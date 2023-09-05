{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "iam",
      "Effect": "Allow",
      "Action": [
        "iam:*"
      ],
      "Resource": [
        "arn:aws:iam::${account_id}:policy/DAReferenceGeneratorLambdaPolicy${title(environment)}",
        "arn:aws:iam::${account_id}:policy/da-reference-generator-${environment}-vpc-policy",
        "arn:aws:iam::${account_id}:policy/DaReferenceCounterTableAccessPolicy${title(environment)}",
        "arn:aws:iam::${account_id}:role/da*"
      ]
    }
  ]
}
