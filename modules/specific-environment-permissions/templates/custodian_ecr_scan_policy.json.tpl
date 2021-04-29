{
  "Version": "2012-10-17",
  "Statement": [
    {
       "Sid": "",
       "Effect": "Allow",
       "Action": [
         "lambda:GetFunction",
         "lambda:UpdateFunctionCode",
         "lambda:TagResource",
         "lambda:AddPermission"
       ],
       "Resource": "arn:aws:lambda:eu-west-2:${account_id}:function:custodian-ecr-vulnerability-scanning-enabled"
     },
     {
       "Sid": "",
       "Effect": "Allow",
       "Action": [
         "events:DescribeRule",
         "events:PutRule",
         "events:ListTargetsByRule"
       ],
       "Resource": "arn:aws:events:eu-west-2:${account_id}:rule/custodian-ecr-vulnerability-scanning-enabled"
     }
  ]
}
