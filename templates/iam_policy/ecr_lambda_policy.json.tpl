{
  "Version" : "2012-10-17",
  "Statement" : [
    {
      "Sid" : "AllowPushPull",
      "Effect" : "Allow",
      "Principal" : {
        "AWS" : [
          "arn:aws:iam::${staging_account_number}:root",
          "arn:aws:iam::${prod_account_number}:root",
          "arn:aws:iam::${intg_account_number}:root"
        ]
      },
      "Action" : [
        "ecr:BatchCheckLayerAvailability",
        "ecr:BatchGetImage",
        "ecr:CompleteLayerUpload",
        "ecr:GetDownloadUrlForLayer",
        "ecr:InitiateLayerUpload",
        "ecr:PutImage",
        "ecr:UploadLayerPart"
        ]
    },
    {
      "Sid" : "LambdaECRImageCrossAccountRetrievalPolicy",
      "Effect" : "Allow",
      "Principal" : {
        "Service" : "lambda.amazonaws.com"
      },
      "Action" : [
        "ecr:BatchGetImage",
        "ecr:GetDownloadUrlForLayer"
      ],
      "Condition" : {
        "ForAnyValue:StringLike" : {
          "aws:sourceARN" : [
            "arn:aws:lambda:eu-west-2:${staging_account_number}:function:*",
            "arn:aws:lambda:eu-west-2:${intg_account_number}:function:*",
            "arn:aws:lambda:eu-west-2:${prod_account_number}:function:*"
          ]
        }
     }
    }
  ]
}
