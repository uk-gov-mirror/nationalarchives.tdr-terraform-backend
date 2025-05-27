{
  "Version": "2012-10-17",
  "Statement": [
    {
       "Sid": "",
       "Effect": "Allow",
       "Action": [
         "lambda:AddPermission",
         "lambda:GetFunction",
         "lambda:TagResource",
         "lambda:GetFunctionConfiguration",
         "lambda:UpdateFunctionCode"
       ],
       "Resource": "arn:aws:lambda:eu-west-2:${account_id}:function:custodian-ecr-vulnerability-scanning-enabled"
     },
     {
       "Sid": "",
       "Effect": "Allow",
       "Action": [
         "events:DescribeRule",
         "events:ListTargetsByRule",
         "events:PutRule"
       ],
       "Resource": "arn:aws:events:eu-west-2:${account_id}:rule/custodian-ecr-vulnerability-scanning-enabled"
     }
  ]
}
