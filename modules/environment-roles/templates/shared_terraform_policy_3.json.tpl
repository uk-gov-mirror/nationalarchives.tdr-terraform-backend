{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "wafregional",
      "Effect": "Allow",
      "Action": [
        "waf-regional:AssociateWebACL",
        "waf-regional:CreateByteMatchSet",
        "waf-regional:CreateGeoMatchSet",
        "waf-regional:CreateIPSet",
        "waf-regional:CreateRegexMatchSet",
        "waf-regional:CreateRule",
        "waf-regional:CreateRuleGroup",
        "waf-regional:CreateWebACL",
        "waf-regional:DeleteByteMatchSet",
        "waf-regional:DeleteGeoMatchSet",
        "waf-regional:DeleteIPSet",
        "waf-regional:DeleteRegexMatchSet",
        "waf-regional:DeleteRule",
        "waf-regional:DeleteRuleGroup",
        "waf-regional:DeleteWebACL",
        "waf-regional:DisassociateWebACL",
        "waf-regional:GetByteMatchSet",
        "waf-regional:GetChangeToken",
        "waf-regional:GetChangeTokenStatus",
        "waf-regional:GetGeoMatchSet",
        "waf-regional:GetIPSet",
        "waf-regional:GetLoggingConfiguration",
        "waf-regional:GetPermissionPolicy",
        "waf-regional:GetRule",
        "waf-regional:GetRuleGroup",
        "waf-regional:GetWebACL",
        "waf-regional:GetWebACLForResource",
        "waf-regional:ListTagsForResource",
        "waf-regional:PutLoggingConfiguration",
        "waf-regional:TagResource",
        "waf-regional:UntagResource",
        "waf-regional:UpdateByteMatchSet",
        "waf-regional:UpdateGeoMatchSet",
        "waf-regional:UpdateIPSet",
        "waf-regional:UpdateRegexMatchSet",
        "waf-regional:UpdateRule",
        "waf-regional:UpdateRuleGroup",
        "waf-regional:UpdateWebACL"
      ],
      "Resource": "*"
    },
    {
      "Sid": "securityhub",
      "Effect": "Allow",
      "Action": [
        "securityhub:BatchDisableStandards",
        "securityhub:BatchEnableStandards",
        "securityhub:DescribeHub",
        "securityhub:DescribeStandards",
        "securityhub:DescribeStandardsControls",
        "securityhub:DisableSecurityHub",
        "securityhub:EnableSecurityHub",
        "securityhub:GetEnabledStandards",
        "securityhub:UpdateStandardsControl"
      ],
      "Resource": "*"
    },
    {
      "Sid": "cloudtrail",
      "Effect": "Allow",
      "Action": [
        "cloudtrail:AddTags",
        "cloudtrail:CreateTrail",
        "cloudtrail:DeleteTrail",
        "cloudtrail:DescribeTrails",
        "cloudtrail:GetEventSelectors",
        "cloudtrail:GetTrail",
        "cloudtrail:GetTrailStatus",
        "cloudtrail:ListTags",
        "cloudtrail:PutEventSelectors",
        "cloudtrail:RemoveTags",
        "cloudtrail:StartLogging",
        "cloudtrail:StopLogging",
        "cloudtrail:UpdateTrail"
      ],
      "Resource": "*"
    }
  ]
}
