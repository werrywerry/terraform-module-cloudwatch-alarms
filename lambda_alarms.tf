locals {
  lambda_list = [for lambda_obj in var.resource_list["lambdas"] : lambda_obj.lambda]
}

resource "aws_cloudwatch_metric_alarm" "success_rate" {
  for_each = { for idx, lambda_obj in local.lambda_list : idx => lambda_obj }

  alarm_name        = format("%s-success-rate", each.value)
  alarm_description = format("Success rate for %s", each.value)

  actions_enabled           = var.actions_enabled
  alarm_actions             = var.actions_alarm
  ok_actions                = var.actions_ok
  insufficient_data_actions = var.actions_insufficient_data

  comparison_operator = "LessThanThreshold"
  threshold           = var.threshold
  evaluation_periods  = var.evaluation_periods
  treat_missing_data  = "notBreaching"

  metric_query {
    id          = "e1"
    expression  = "(m1-m2)/m1*100"
    label       = "Success Rate"
    return_data = "true"
  }

  metric_query {
    id = "m1"

    metric {
      metric_name = "Invocations"
      namespace   = "AWS/Lambda"
      period      = var.period
      stat        = "Sum"
      unit        = "Count"

      dimensions = {
        FunctionName = each.value
      }
    }
  }

  metric_query {
    id = "m2"

    metric {
      metric_name = "Errors"
      namespace   = "AWS/Lambda"
      period      = var.period
      stat        = "Sum"
      unit        = "Count"

      dimensions = {
        FunctionName = each.value
      }
    }
  }

  tags = var.tags
}


resource "aws_cloudwatch_metric_alarm" "errors_alarm" {
  for_each = { for idx, lambda_obj in local.lambda_list : idx => lambda_obj }

  alarm_name          = "${each.value}-Errors"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  period              = 60
  threshold           = 1
  alarm_description   = "Alarm triggered if Lambda function errors exceed threshold"
  alarm_actions       = var.actions_alarm

  dimensions = {
    FunctionName = each.value
  }

  metric_name = "Errors"
  namespace   = "AWS/Lambda"
  statistic   = "Sum"
}

resource "aws_cloudwatch_metric_alarm" "duration_alarm" {
  for_each = { for idx, lambda_obj in local.lambda_list : idx => lambda_obj }

  alarm_name          = "${each.value}-Duration"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  period              = 60
  threshold           = 3

  alarm_description = "Alarm triggered if Lambda function duration exceeds threshold"
  alarm_actions     = var.actions_alarm

  dimensions = {
    FunctionName = each.value
  }

  metric_name = "Duration"
  namespace   = "AWS/Lambda"
  statistic   = "Average"
}

resource "aws_cloudwatch_metric_alarm" "throttles_alarm" {
  for_each = { for idx, lambda_obj in local.lambda_list : idx => lambda_obj }

  alarm_name          = "${each.value}-Throttles"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  period              = 60
  threshold           = 2

  alarm_description = "Alarm triggered if Lambda function throttles exceed threshold"
  alarm_actions     = var.actions_alarm

  dimensions = {
    FunctionName = each.value
  }

  metric_name = "Throttles"
  namespace   = "AWS/Lambda"
  statistic   = "Sum"
}

resource "aws_cloudwatch_metric_alarm" "concurrent_executions_alarm" {
  for_each = { for idx, lambda_obj in local.lambda_list : idx => lambda_obj }
  alarm_name          = "${each.value}-ConcurrentExecutions"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  period              = 60
  threshold           = 4

  alarm_description = "Alarm triggered if Lambda function concurrent executions exceed threshold"
  alarm_actions     = var.actions_alarm

  dimensions = {
    FunctionName = each.value
  }

  metric_name = "ConcurrentExecutions"
  namespace   = "AWS/Lambda"
  statistic   = "Maximum"
}