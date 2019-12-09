{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "elb",
      "Effect": "Allow",
      "Action": [
        "elasticloadbalancing:AddTags",
        "elasticloadbalancing:CreateListener",
        "elasticloadbalancing:CreateLoadBalancer",
        "elasticloadbalancing:DeleteListener",
        "elasticloadbalancing:DeleteLoadBalancer",
        "elasticloadbalancing:DeleteTargetGroup",
        "elasticloadbalancing:DeregisterTargets",
        "elasticloadbalancing:ModifyLoadBalancerAttributes",
        "elasticloadbalancing:ModifyTargetGroupAttributes",
        "elasticloadbalancing:RegisterTargets"
      ],
      "Resource": [
        "arn:aws:elasticloadbalancing:eu-west-2:328920706552:listener/app/tdr_${app_name}_load_balancer_${var.environment}/*/*",
        "arn:aws:elasticloadbalancing:eu-west-2:328920706552:listener/net/tdr_${app_name}_load_balancer_${var.environment}/*/*",
        "arn:aws:elasticloadbalancing:eu-west-2:328920706552:loadbalancer/net/tdr_${app_name}_load_balancer_${var.environment}/*",
        "arn:aws:elasticloadbalancing:eu-west-2:328920706552:targetgroup/*"
      ]
    },
    {
      "Sid": "elb",
      "Effect": "Allow",
      "Action": [
        "elasticloadbalancing:CreateTargetGroup",
        "elasticloadbalancing:DescribeListeners",
        "elasticloadbalancing:DescribeLoadBalancerAttributes",
        "elasticloadbalancing:DescribeLoadBalancers",
        "elasticloadbalancing:DescribeTags",
        "elasticloadbalancing:DescribeTargetGroupAttributes",
        "elasticloadbalancing:DescribeTargetGroups",
        "elasticloadbalancing:DescribeTargetHealth"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}