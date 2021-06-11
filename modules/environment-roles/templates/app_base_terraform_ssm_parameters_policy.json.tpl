{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ssm",
      "Effect": "Allow",
      "Action": [
        "ssm:AddTagsToResource",
        "ssm:DeleteParameter",
        "ssm:GetParameter",
        "ssm:GetParameters",
        "ssm:ListTagsForResource",
        "ssm:PutParameter"
      ],
      "Resource": [
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/${environment}/slack/notification/webhook",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/${environment}/${app_name}/admin/password",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/${environment}/${app_name}/admin/user",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/${environment}/${app_name}/backend_checks_client/secret",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/${environment}/${app_name}/client/secret",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/${environment}/${app_name}/configuration_properties",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/${environment}/${app_name}/database/url",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/${environment}/${app_name}/database/username",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/${environment}/${app_name}/database/password",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/${environment}/${app_name}/database/api/password",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/${environment}/${app_name}/database/migrations/password",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/${environment}/${app_name}/govuk_notify/api_key",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/${environment}/${app_name}/govuk_notify/template_id",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/${environment}/${app_name}/password",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/${environment}/${app_name}/realm_admin_client/secret",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/${environment}/${app_name}/reporting_client/secret",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/${environment}/${app_name}/user_admin_client/secret",
      ]
    }
  ]
}
