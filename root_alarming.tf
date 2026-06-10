# TDRD-1268
# Alarming/Alerting infrastructure
# * Create an event bridge for alarms to be forwarded to
# * Create a rule to forward CloudWatch Alarm State Change to alarms bus
# * Create a role for the rule to run as
# * Create a role that can be consumed from tdr-terraform-environments for creating alarms
# * Create slack API destination
# * Create rules for sending alterts to Slack
# TDRD-1436
# * Create rule for sending alerts to Jira

resource "aws_cloudwatch_event_bus" "alarms_event_bus" {
  name = "tdr-alarms"
}

# Get the admin role without hardcoding
data "aws_iam_roles" "admin_sso_role" {
  name_regex  = "AWSReservedSSO_AdministratorAccess_*"
  path_prefix = "/aws-reserved/sso.amazonaws.com/"
}

resource "aws_secretsmanager_secret" "alarms_slack_token" {
  name        = "alarms_slack_token_tdr_notifier"
  description = "Oauth token for TDR Notfier slack app"
}

data "aws_secretsmanager_secret_version" "alarms_slack_token" {
  secret_id = aws_secretsmanager_secret.alarms_slack_token.id
}

resource "aws_secretsmanager_secret" "alarms_jira_token" {
  name        = "alarms_jira_token_tdr_notifier"
  description = "<username>:<api_key> base64 encoded"
}

data "aws_secretsmanager_secret_version" "alarms_jira_token" {
  secret_id = aws_secretsmanager_secret.alarms_jira_token.id
}

#### IAM ####
data "aws_iam_policy_document" "alarms_trust" {
  statement {
    sid     = "AlarmsTrust"
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_ssm_parameter.mgmt_account_number.value]
    }
  }
}

data "aws_iam_policy_document" "alarms_role" {
  statement {
    sid       = "TDRAlarmsPutBus"
    effect    = "Allow"
    actions   = ["events:PutEvents"]
    resources = [aws_cloudwatch_event_bus.alarms_event_bus.arn]
  }
  statement {
    sid     = "TDRAlarmsInvokeApi"
    effect  = "Allow"
    actions = ["events:InvokeApiDestination"]
    resources = [
      aws_cloudwatch_event_api_destination.alarms_slack_api.arn,
      aws_cloudwatch_event_api_destination.alarms_jira_api.arn
    ]
  }
  statement {
    sid    = "TDRAlarmsConnectionSecrets"
    effect = "Allow"
    actions = ["secretsmanager:CreateSecret",
      "secretsmanager:UpdateSecret",
      "secretsmanager:DescribeSecret",
      "secretsmanager:DeleteSecret",
      "secretsmanager:GetSecretValue",
      "secretsmanager:PutSecretValue"
    ]
    resources = ["arn:aws:secretsmanager:*:*:secret:events!connection/*"]
  }
}

resource "aws_iam_policy" "alarms_role" {
  name        = "TDRAlarmsBusRole"
  description = "Policy for eventbridge execution"
  policy      = data.aws_iam_policy_document.alarms_role.json
}

resource "aws_iam_role" "alarms_role" {
  name               = "TDRAlarmsBus"
  assume_role_policy = data.aws_iam_policy_document.alarms_trust.json
}

resource "aws_iam_role_policy_attachment" "alarms_role" {
  role       = aws_iam_role.alarms_role.name
  policy_arn = aws_iam_policy.alarms_role.arn
}

# Role for deploying alarms in to manangement from environments stack
data "aws_iam_policy_document" "alarms_deployer_role" {
  statement {
    sid    = "DeployAlarms"
    effect = "Allow"
    actions = [
      "cloudwatch:PutMetricAlarm",
      "cloudwatch:PutCompositeAlarm",
      "cloudwatch:DeleteAlarms",
      "cloudwatch:DescribeAlarms",
      "cloudwatch:DescribeAlarmHistory",
      "cloudwatch:DescribeAlarmsForMetric",
      "cloudwatch:SetAlarmState",
      "cloudwatch:EnableAlarmActions",
      "cloudwatch:DisableAlarmActions",
      "cloudwatch:GetAlarmMuteRule",
      "cloudwatch:PutAlarmMuteRule",
      "cloudwatch:DeleteAlarmMuteRule",
      "cloudwatch:TagResource",
      "cloudwatch:UntagResource",
      "cloudwatch:ListTagsForResource"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "alarms_deployer_trust" {
  statement {
    sid     = "DeployAlarmsTrust"
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_ssm_parameter.mgmt_account_number.value}:role/TDRGithubTerraformAssumeRoleIntg",
        "arn:aws:iam::${data.aws_ssm_parameter.mgmt_account_number.value}:role/TDRGithubTerraformAssumeRoleDev",
        "arn:aws:iam::${data.aws_ssm_parameter.mgmt_account_number.value}:role/TDRGithubTerraformAssumeRoleStaging",
        "arn:aws:iam::${data.aws_ssm_parameter.mgmt_account_number.value}:role/TDRGithubTerraformAssumeRoleProd",
        one(data.aws_iam_roles.admin_sso_role.arns)
      ]
    }
  }
}

resource "aws_iam_policy" "alarms_deployer_role" {
  name        = "TDRTerraformAlarmsDeployerRole"
  description = "Policy for creating cloudwatch alarms"
  policy      = data.aws_iam_policy_document.alarms_deployer_role.json
}

resource "aws_iam_role" "alarms_deployer_role" {
  name               = "TDRTerraformAlarmsDeployerRole"
  assume_role_policy = data.aws_iam_policy_document.alarms_deployer_trust.json
}

resource "aws_iam_role_policy_attachment" "alarms_deployer_role" {
  role       = aws_iam_role.alarms_deployer_role.name
  policy_arn = aws_iam_policy.alarms_deployer_role.arn
}

#### Slack API Destination ####
resource "aws_cloudwatch_event_connection" "alarms_slack_api" {
  name               = "slack_api_alarms_connection"
  description        = "connection for slack_api_alarms"
  authorization_type = "API_KEY"

  auth_parameters {
    api_key {
      key = "Authorization"

      value = "Bearer ${data.aws_secretsmanager_secret_version.alarms_slack_token.secret_string}"
    }
  }
}

resource "aws_cloudwatch_event_api_destination" "alarms_slack_api" {
  name                             = "slack_api_alarms"
  description                      = "send alarms to slack"
  invocation_endpoint              = "https://slack.com/api/chat.postMessage"
  http_method                      = "POST"
  invocation_rate_limit_per_second = 5
  connection_arn                   = aws_cloudwatch_event_connection.alarms_slack_api.arn
}

#### Forwarding from default bus for alarm state ####
resource "aws_cloudwatch_event_rule" "alarms_default_cloudwatch_alarm_state_change" {
  name        = "alarm-state-changes"
  description = "Take the alarm state change events from the default bus"
  event_pattern = jsonencode({
    source      = ["aws.cloudwatch"],
    detail-type = ["CloudWatch Alarm State Change"]
  })
  event_bus_name = "default"
}

resource "aws_cloudwatch_event_target" "alarm_default_cloudwatch_alarm_state_change_to_ddt_alarms_bus_target" {
  rule     = aws_cloudwatch_event_rule.alarms_default_cloudwatch_alarm_state_change.name
  arn      = aws_cloudwatch_event_bus.alarms_event_bus.arn
  role_arn = aws_iam_role.alarms_role.arn
}

#### Rules ####
resource "aws_cloudwatch_log_group" "alarms_all" {
  name              = "/aws/events/tdr_alarms_all"
  retention_in_days = 7
}

# Catch any events on this bus and dump to cloudwatch
resource "aws_cloudwatch_event_rule" "alarms_all_to_cloudwatch" {
  name           = "all-to-cloudwatch-logs"
  description    = "Dump all messages to cloudwatch logs"
  event_bus_name = aws_cloudwatch_event_bus.alarms_event_bus.name
  event_pattern  = jsonencode({ "detail-type" : [{ "exists" : true }] })
}

resource "aws_cloudwatch_event_target" "alarms_cloudwatch_all" {
  rule           = aws_cloudwatch_event_rule.alarms_all_to_cloudwatch.name
  arn            = aws_cloudwatch_log_group.alarms_all.arn
  event_bus_name = aws_cloudwatch_event_bus.alarms_event_bus.name
}

# Catch any alarm state change to ALARM and send to cloudwatch
# Skip if alarm name is prefix with "Muted:"
resource "aws_cloudwatch_event_rule" "alarms_state_change_any_environment_any_alarm" {
  name        = "alarm-state-changes-ALARM-all-slack"
  description = "Catch all state changes to ALARM and send to slack if the alarm name is not prefixed with 'Muted:'"
  event_pattern = jsonencode({
    source               = ["aws.cloudwatch"],
    detail-type          = ["CloudWatch Alarm State Change"]
    "detail.state.value" = ["ALARM"]
    "detail.alarmName"   = [{ "anything-but" : { "prefix" : "Muted:" } }]
  })
  event_bus_name = aws_cloudwatch_event_bus.alarms_event_bus.name
}

resource "aws_cloudwatch_event_target" "alarm_state_change_any_environment_any_alarm_slack" {
  rule           = aws_cloudwatch_event_rule.alarms_state_change_any_environment_any_alarm.name
  arn            = aws_cloudwatch_event_api_destination.alarms_slack_api.arn
  event_bus_name = aws_cloudwatch_event_bus.alarms_event_bus.name
  role_arn       = aws_iam_role.alarms_role.arn

  input_transformer {
    input_paths = {
      alarmName = "$.detail.alarmName",
      resources = "$.resources[0]",
      state     = "$.detail.state.value",
      time      = "$.detail.state.timestamp"
    }

    input_template = templatefile("${path.module}/templates/alarms/alarm_notification_slack.json", {
      channel_id  = module.global_parameters.slack_channels.da-tdr-cloudwatch-alarms
      alarm_state = ":helmet_with_white_cross:"
    })
  }
}

# Catch RDS alarm state changes to OK and send to cloudwatch
resource "aws_cloudwatch_event_rule" "alarms_state_change_any_environment_rds_ok" {
  name        = "alarm-state-changes-OK-rds-slack"
  description = "Catch RDS state changes to OK and send to slack"
  event_pattern = jsonencode({
    source                                                     = ["aws.cloudwatch"],
    detail-type                                                = ["CloudWatch Alarm State Change"]
    "detail.state.value"                                       = ["OK"]
    "detail.configuration.metrics.metricStat.metric.namespace" = ["AWS/RDS"]
  })
  event_bus_name = aws_cloudwatch_event_bus.alarms_event_bus.name
}

resource "aws_cloudwatch_event_target" "alarm_state_change_any_environment_rds_ok_slack" {
  rule           = aws_cloudwatch_event_rule.alarms_state_change_any_environment_rds_ok.name
  arn            = aws_cloudwatch_event_api_destination.alarms_slack_api.arn
  event_bus_name = aws_cloudwatch_event_bus.alarms_event_bus.name
  role_arn       = aws_iam_role.alarms_role.arn

  input_transformer {
    input_paths = {
      alarmName = "$.detail.alarmName",
      resources = "$.resources[0]",
      state     = "$.detail.state.value",
      time      = "$.detail.state.timestamp"
    }

    input_template = templatefile("${path.module}/templates/alarms/alarm_notification_slack.json", {
      channel_id  = module.global_parameters.slack_channels.da-tdr-cloudwatch-alarms
      alarm_state = ":green-tick:"
    })
  }
}

# Catch ALB alarm state changes to OK and send to cloudwatch
# Ignore Muted
resource "aws_cloudwatch_event_rule" "alarms_state_change_any_environment_alb_ok" {
  name        = "alarm-state-changes-OK-alb-slack"
  description = "Catch ALB state changes to OK and send to slack"
  event_pattern = jsonencode({
    source                                                     = ["aws.cloudwatch"],
    detail-type                                                = ["CloudWatch Alarm State Change"]
    "detail.state.value"                                       = ["OK"]
    "detail.configuration.metrics.metricStat.metric.namespace" = ["AWS/ApplicationELB"]
    "detail.alarmName"                                         = [{ "anything-but" : { "prefix" : "Muted:" } }]
  })
  event_bus_name = aws_cloudwatch_event_bus.alarms_event_bus.name
}

resource "aws_cloudwatch_event_target" "alarm_state_change_any_environment_alb_ok_slack" {
  rule           = aws_cloudwatch_event_rule.alarms_state_change_any_environment_alb_ok.name
  arn            = aws_cloudwatch_event_api_destination.alarms_slack_api.arn
  event_bus_name = aws_cloudwatch_event_bus.alarms_event_bus.name
  role_arn       = aws_iam_role.alarms_role.arn

  input_transformer {
    input_paths = {
      alarmName = "$.detail.alarmName",
      resources = "$.resources[0]",
      state     = "$.detail.state.value",
      time      = "$.detail.state.timestamp"
    }

    input_template = templatefile("${path.module}/templates/alarms/alarm_notification_slack.json", {
      channel_id  = module.global_parameters.slack_channels.da-tdr-cloudwatch-alarms
      alarm_state = ":green-tick:"
    })
  }
}

# Catch Lambda Throttle alarm state changes to OK and send to cloudwatch
resource "aws_cloudwatch_event_rule" "alarms_state_change_any_environment_lambda_throttle_ok" {
  name        = "alarm-state-changes-OK-lambda-throttle-slack"
  description = "Catch Lambda Throttle state changes to OK and send to slack"
  event_pattern = jsonencode({
    source                                                     = ["aws.cloudwatch"],
    detail-type                                                = ["CloudWatch Alarm State Change"]
    "detail.state.value"                                       = ["OK"]
    "detail.configuration.metrics.metricStat.metric.namespace" = ["AWS/Lambda"]
    "detail.configuration.metrics.metricStat.metric.name"      = ["Throttles"]
  })
  event_bus_name = aws_cloudwatch_event_bus.alarms_event_bus.name
}

resource "aws_cloudwatch_event_target" "alarm_state_change_any_environment_lambda_throttle_ok_slack" {
  rule           = aws_cloudwatch_event_rule.alarms_state_change_any_environment_lambda_throttle_ok.name
  arn            = aws_cloudwatch_event_api_destination.alarms_slack_api.arn
  event_bus_name = aws_cloudwatch_event_bus.alarms_event_bus.name
  role_arn       = aws_iam_role.alarms_role.arn

  input_transformer {
    input_paths = {
      alarmName = "$.detail.alarmName",
      resources = "$.resources[0]",
      state     = "$.detail.state.value",
      time      = "$.detail.state.timestamp"
    }

    input_template = templatefile("${path.module}/templates/alarms/alarm_notification_slack.json", {
      channel_id  = module.global_parameters.slack_channels.da-tdr-cloudwatch-alarms
      alarm_state = ":green-tick:"
    })
  }
}

#### Jira ####
resource "aws_cloudwatch_event_connection" "alarms_jira_api" {
  name               = "jira_api_alarms_connection"
  description        = "connection for jira_api_alarms"
  authorization_type = "API_KEY"

  auth_parameters {
    api_key {
      key   = "Authorization"
      value = "Basic ${data.aws_secretsmanager_secret_version.alarms_jira_token.secret_string}"
    }
  }
}

resource "aws_cloudwatch_event_api_destination" "alarms_jira_api" {
  name                             = "jira_api_alarms"
  description                      = "send alarms to jira"
  invocation_endpoint              = format("https://api.atlassian.com/ex/jira/%s/rest/api/3/issue", module.global_parameters.jira.cloud_instance_id)
  http_method                      = "POST"
  invocation_rate_limit_per_second = 5
  connection_arn                   = aws_cloudwatch_event_connection.alarms_jira_api.arn
}

# Catch any alarm state change to ALARM in prod and send to cloudwatch
# Skip if alarm name is prefix with "Muted:"
resource "aws_cloudwatch_event_rule" "alarms_state_change_any_environment_any_alarm_jira" {
  name        = "alarm-state-changes-ALARM-all-jira"
  description = "Catch all state changes to ALARM in prod and send to Jira if the alarm name is not prefixed with 'Muted:'"
  event_pattern = jsonencode({
    source      = ["aws.cloudwatch"],
    detail-type = ["CloudWatch Alarm State Change"]
    "detail.configuration.metrics.accountId" : [data.aws_ssm_parameter.prod_account_number.value]
    "detail.state.value" = ["ALARM"]
    "detail.alarmName"   = [{ "anything-but" : { "prefix" : "Muted:" } }]
  })
  event_bus_name = aws_cloudwatch_event_bus.alarms_event_bus.name
}

resource "aws_cloudwatch_event_target" "alarm_state_change_any_environment_any_alarm_jira" {
  rule           = aws_cloudwatch_event_rule.alarms_state_change_any_environment_any_alarm_jira.name
  arn            = aws_cloudwatch_event_api_destination.alarms_jira_api.arn
  event_bus_name = aws_cloudwatch_event_bus.alarms_event_bus.name
  role_arn       = aws_iam_role.alarms_role.arn

  input_transformer {
    input_paths = {
      alarmName = "$.detail.alarmName",
      resources = "$.resources[0]",
      state     = "$.detail.state.value",
      time      = "$.detail.state.timestamp"
    }
    input_template = templatefile("${path.module}/templates/alarms/alarm_notification_jira.json", {})
  }
}
