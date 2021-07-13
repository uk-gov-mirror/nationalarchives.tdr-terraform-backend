{
  "Version": "2012-10-17",

  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": [
        "sts:AssumeRole"
      ],
      "Resource": [
        "arn:aws:iam::${account_number}:role/TDRJenkinsDeployServiceUnavailableRole${env_title_case}"
      ]
    }
  ]
}
