{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "lambda",
      "Effect": "Allow",
      "Action": [
      ],
      "Resource": "arn:aws:lambda:eu-west-2:${account_id}:function:${function_name}_${environment}"
    }
  ]
}