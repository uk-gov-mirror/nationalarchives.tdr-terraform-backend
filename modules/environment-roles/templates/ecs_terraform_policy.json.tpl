{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ecs",
      "Effect": "Allow",
      "Action": [
        "ecs:CreateService",
        "ecs:DeleteCluster",
        "ecs:DeleteService",
        "ecs:DescribeServices",
        "ecs:UpdateService",
        "ecs:DescribeClusters"
      ],
      "Resource": [
        "arn:aws:ecs:eu-west-2:328920706552:cluster/${app_name}_${var.environment}",
        "arn:aws:ecs:eu-west-2:328920706552:service/${app_name}_${var.environment}/${app_name}_service_${var.environment}"
      ]
    },
    {
      "Sid": "ecs",
      "Effect": "Allow",
      "Action": [
        "ecs:CreateCluster",
        "ecs:DeregisterTaskDefinition",
        "ecs:DescribeTaskDefinition",
        "ecs:RegisterTaskDefinition"
      ],
      "Resource": "*"
    }

  ]
}