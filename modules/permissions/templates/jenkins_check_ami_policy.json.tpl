{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "ec2:DescribeImages",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::tdr-terraform-state-jenkins",
        "arn:aws:s3:::tdr-terraform-state-jenkins/jenkins-terraform-state"
      ]
    }
  ]
}