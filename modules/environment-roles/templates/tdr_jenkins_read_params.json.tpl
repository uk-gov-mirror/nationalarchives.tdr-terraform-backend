{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": "ssm:DescribeParameters",
      "Resource": "*"
    },
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": "ssm:GetParameters",
      "Resource": [
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/${environment}/keycloak/admin/*",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/${environment}/keycloak/client/secret",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/${environment}/keycloak/backend_checks_client/secret",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/${environment}/keycloak/realm_admin_client/secret"
      ]
    }
  ]
}