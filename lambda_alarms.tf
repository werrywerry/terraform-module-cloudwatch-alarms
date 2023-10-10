resource "aws_cloudwatch_metric_alarm" "success_rate" {
  for_each = { for idx, lambda_obj in local.lambda_list : idx => lambda_obj }

  alarm_name        = format("%s-success-rate", each.value.lambda)
  alarm_description = format("Success rate for %s", each.value.lambda)

  alarm_actions = [local.sns_topic_arn]

  comparison_operator = "LessThanThreshold"
  threshold           = var.threshold #% of executions that were successfull
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
        FunctionName = each.value.lambda
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
        FunctionName = each.value.lambda
      }
    }
  }

  tags = var.tags
}


resource "aws_cloudwatch_metric_alarm" "errors_alarm" {
  for_each = { for idx, lambda_obj in local.lambda_list : idx => lambda_obj }

  alarm_name          = "${each.value.lambda}-Errors"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  period              = 60
  threshold           = 1 #Errors
  alarm_description   = "Alarm triggered if Lambda function errors exceed threshold"
  alarm_actions       = [local.sns_topic_arn]

  dimensions = {
    FunctionName = each.value.lambda
  }

  metric_name = "Errors"
  namespace   = "AWS/Lambda"
  statistic   = "Sum"
}

resource "aws_cloudwatch_metric_alarm" "duration_alarm" {
  for_each = { for idx, lambda_obj in local.lambda_list : idx => lambda_obj }

  alarm_name          = "${each.value.lambda}-Duration"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  period              = 60
  threshold           = 0.75 * each.value.timeout #Milliseconds

  alarm_description = "Alarm triggered if Lambda function duration exceeds threshold"
  alarm_actions     = [local.sns_topic_arn]

  dimensions = {
    FunctionName = each.value.lambda
  }

  metric_name = "Duration"
  namespace   = "AWS/Lambda"
  statistic   = "Average"
}

resource "aws_cloudwatch_log_metric_filter" "memory_used" {
  for_each = { for idx, lambda_obj in local.lambda_list : idx => lambda_obj }

  name           = "${each.value.lambda}-memory-used-filter"
  pattern        = "REPORT RequestId: * Duration: * Billed Duration: * Memory Size: * Max Memory Used: * MB"
  log_group_name = "/aws/lambda/${each.value.lambda}"

  metric_transformation {
    name      = "MaxMemoryUsed"
    namespace = "AWS/Lambda"
    value     = "$14"
  }
}

resource "aws_cloudwatch_metric_alarm" "memory_alarm" {
  for_each = { for idx, lambda_obj in local.lambda_list : idx => lambda_obj }

  alarm_name          = "${each.value.lambda}-HighMemoryUsage"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  period              = 60
  threshold           = 0.9 * each.value.memory # Megabytes

  alarm_description = "Alarm triggered if Lambda function memory usage exceeds threshold"
  alarm_actions     = [local.sns_topic_arn]

  dimensions = {
    FunctionName = each.value.lambda
  }

  metric_name = "MaxMemoryUsed"
  namespace   = "AWS/Lambda"
  statistic   = "Maximum"
}

resource "aws_cloudwatch_metric_alarm" "throttles_alarm" {
  for_each = { for idx, lambda_obj in local.lambda_list : idx => lambda_obj }

  alarm_name          = "${each.value.lambda}-Throttles"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  period              = 60
  threshold           = 1 #Throttles

  alarm_description = "Alarm triggered if Lambda function throttles exceed threshold"
  alarm_actions     = [local.sns_topic_arn]

  dimensions = {
    FunctionName = each.value.lambda
  }

  metric_name = "Throttles"
  namespace   = "AWS/Lambda"
  statistic   = "Sum"
}

resource "aws_cloudwatch_metric_alarm" "concurrent_executions_alarm" {
  for_each            = { for idx, lambda_obj in local.lambda_list : idx => lambda_obj }
  alarm_name          = "${each.value.lambda}-ConcurrentExecutions"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  period              = 60
  threshold           = each.value.concurrency * 0.8  # 80% of the concurrency value for this lambda

  alarm_description = "Alarm triggered if Lambda function concurrent executions exceed threshold"
  alarm_actions     = [local.sns_topic_arn]

  dimensions = {
    FunctionName = each.value.lambda
  }

  metric_name = "ConcurrentExecutions"
  namespace   = "AWS/Lambda"
  statistic   = "Maximum"
}
