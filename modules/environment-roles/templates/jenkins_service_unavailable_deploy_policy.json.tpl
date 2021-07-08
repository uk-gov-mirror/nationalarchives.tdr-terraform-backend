{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ServiceUnavailableDeploy",
      "Effect": "Allow",
      "Action": [
        "elasticloadbalancing:DescribeLoadBalancers",
        "elasticloadbalancing:DescribeListeners",
        "elasticloadbalancing:DescribeTargetGroups"
      ],
      "Resource": "*"
    }
  ]
}
