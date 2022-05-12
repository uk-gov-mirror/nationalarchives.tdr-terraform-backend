{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ServiceUnavailableDeploy",
      "Effect": "Allow",
      "Action": [
        "elasticloadbalancing:DescribeListeners",
        "elasticloadbalancing:DescribeLoadBalancers",
        "elasticloadbalancing:DescribeTargetGroups",
        "elasticloadbalancing:ModifyListener"
      ],
      "Resource": "*"
    }
  ]
}
