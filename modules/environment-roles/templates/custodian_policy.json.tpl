{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ssmglobal",
      "Effect": "Allow",
      "Action" : [
        "ssm:DescribeParameters"
      ],
      "Resource": "arn:aws:ssm:eu-west-2:${account_id}:*"
    },
    {
      "Sid" : "ssm",
      "Effect": "Allow",
      "Action": [
        "ssm:GetParameter"
      ],
      "Resource" : [
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/mgmt/cost_centre",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/mgmt/slack/webhook"
      ]
    },
    {
      "Sid": "route53",
      "Effect": "Allow",
      "Action" : [
        "route53:ListHostedZones"
      ],
      "Resource": "*"
    },
    {
      "Sid": "lambda",
      "Effect": "Allow",
      "Action": [
        "lambda:AddPermission",
        "lambda:CreateFunction",
        "lambda:DeleteFunction",
        "lambda:GetAlias",
        "lambda:GetFunction",
        "lambda:GetFunctionConcurrency",
        "lambda:GetFunctionConfiguration",
        "lambda:GetFunctionEventInvokeConfig",
        "lambda:GetLayerVersion",
        "lambda:GetLayerVersionPolicy",
        "lambda:GetPolicy",
        "lambda:ListVersionsByFunction",
        "lambda:ListTags",
        "lambda:RemovePermission",
        "lambda:UpdateFunctionConfiguration"
      ],
      "Resource": [
        "arn:aws:lambda:eu-west-2:${account_id}:function:cloud-custodian-mailer",
        "arn:aws:lambda:eu-west-2:${account_id}:function:custodian*"
      ]
    }
  ]
}
