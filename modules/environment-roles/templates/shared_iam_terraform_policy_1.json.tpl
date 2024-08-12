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
         "arn:aws:iam::${account_id}:policy/TDRTransferServiceECSExecutionPolicy${title(environment)}",
         "arn:aws:iam::${account_id}:policy/TDRTransferServiceECSTaskPolicy${title(environment)}",
         "arn:aws:iam::${account_id}:role/TDRTransferServiceECSTaskRole${title(environment)}",
         "arn:aws:iam::${account_id}:role/TDRTransferServiceECSExecutionRole${title(environment)}",
         "arn:aws:iam::${account_id}:role/TDRTransferServiceProcessDataload${title(environment)}-role"
       ]
    }
  ]
}
