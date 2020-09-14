{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": [
        "logs:DescribeQueries",
        "tag:GetResources",
        "ec2:DescribeInstances",
        "logs:DescribeLogGroups",
        "cloudwatch:GetMetricData",
        "logs:DescribeLogStreams",
        "ec2:DescribeTags",
        "ec2:DescribeRegions",
        "logs:StartQuery",
        "logs:StopQuery",
        "cloudwatch:GetMetricStatistics",
        "cloudwatch:ListMetrics",
        "logs:GetQueryResults",
        "cloudwatch:DescribeAlarmsForMetric",
        "logs:GetLogEvents",
        "logs:FilterLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
