{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": "logs:CreateLogStream",
      "Resource": [
        "arn:aws:logs:eu-west-2:${account_id}:log-group:terraform-plan-outputs-*",
        "arn:aws:logs:eu-west-2:${account_id}:log-group:terraform-apply-outputs-*"
      ]
    },
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": "logs:PutLogEvents",
      "Resource": [
        "arn:aws:logs:eu-west-2:${account_id}:log-group:terraform-plan-outputs-*:log-stream:*",
        "arn:aws:logs:eu-west-2:${account_id}:log-group:terraform-apply-outputs-*:log-stream:*"
      ]
    }
  ]
}
