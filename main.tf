resource "aws_cloudwatch_metric_alarm" "success_rate" {

  alarm_name        = format("%s-success-rate", var.lambda_function_name)
  alarm_description = format("Success rate for %s", var.lambda_function_name)

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
        FunctionName = var.lambda_function_name
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
        FunctionName = var.lambda_function_name
      }
    }
  }

  tags = var.tags
}


resource "aws_cloudwatch_metric_alarm" "errors_alarm" {
  alarm_name          = "${var.lambda_function_name}-Errors"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  period              = 60
  threshold           = 1
  alarm_description   = "Alarm triggered if Lambda function errors exceed threshold"
  alarm_actions       = var.actions_alarm

  dimensions = {
    FunctionName = var.lambda_function_name
  }

  metric_name = "Errors"
  namespace   = "AWS/Lambda"
  statistic   = "Sum"
}

resource "aws_cloudwatch_metric_alarm" "duration_alarm" {
  alarm_name          = "${var.lambda_function_name}-Duration"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  period              = 60
  threshold           = 3

  alarm_description = "Alarm triggered if Lambda function duration exceeds threshold"
  alarm_actions     = var.actions_alarm

  dimensions = {
    FunctionName = var.lambda_function_name
  }

  metric_name = "Duration"
  namespace   = "AWS/Lambda"
  statistic   = "Average"
}

resource "aws_cloudwatch_metric_alarm" "throttles_alarm" {
  alarm_name          = "${var.name}-Throttles"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  period              = 60
  threshold           = 2

  alarm_description = "Alarm triggered if Lambda function throttles exceed threshold"
  alarm_actions     = var.actions_alarm

  dimensions = {
    FunctionName = var.lambda_function_name
  }

  metric_name = "Throttles"
  namespace   = "AWS/Lambda"
  statistic   = "Sum"
}

resource "aws_cloudwatch_metric_alarm" "concurrent_executions_alarm" {
  alarm_name          = "${var.name}-ConcurrentExecutions"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  period              = 60
  threshold           = 4

  alarm_description = "Alarm triggered if Lambda function concurrent executions exceed threshold"
  alarm_actions     = var.actions_alarm

  dimensions = {
    FunctionName = var.lambda_function_name
  }

  metric_name = "ConcurrentExecutions"
  namespace   = "AWS/Lambda"
  statistic   = "Maximum"
}