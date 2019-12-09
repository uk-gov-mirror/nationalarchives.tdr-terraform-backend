{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "iam",
      "Effect": "Allow",
      "Action": [
        "iam:AddRoleToInstanceProfile",
        "iam:AttachRolePolicy",
        "iam:CreateInstanceProfile",
        "iam:CreatePolicy",
        "iam:CreateRole",
        "iam:DeletePolicy",
        "iam:DeleteRole",
        "iam:DetachRolePolicy",
        "iam:GetPolicy",
        "iam:GetPolicyVersion",
        "iam:GetRole",
        "iam:ListAttachedRolePolicies",
        "iam:ListInstanceProfilesForRole",
        "iam:ListPolicyVersions",
        "iam:PassRole",
        "iam:TagRole",
        "iam:UpdateAssumeRolePolicy"
      ],
      "Resource": [
        "arn:aws:iam::${account_id}:policy/${app_name}_ecs_execution_policy_${var.environment}",
        "arn:aws:iam::${account_id}:policy/${app_name}_ecs_task_policy_${var.environment}",
        "arn:aws:iam::${account_id}:role/${app_name}_ecs_execution_role_${var.environment}",
        "arn:aws:iam::${account_id}:role/${app_name}_ecs_task_role_${var.environment}",
        "arn:aws:iam::${account_id}:role/aws-service-role/ecs.amazonaws.com/AWSServiceRoleForECS"`

      ]
    },
    {
      "Sid": "iam",
      "Effect": "Allow",
      "Action": [
        "iam:DeleteInstanceProfile",
        "iam:RemoveRoleFromInstanceProfile"
      ],
      "Resource": ["*"]
    }

  ]
}