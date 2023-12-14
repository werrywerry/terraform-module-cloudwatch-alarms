resource "aws_cloudwatch_metric_alarm" "api_4xx_errors_alarm" {
  for_each = { for idx, api in local.merged_apis : idx => api }

  alarm_name          = "${each.value.api}-4xxErrors"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "4XXError"
  namespace           = "AWS/ApiGateway"
  period              = "300"
  statistic           = "SampleCount"
  threshold           = each.value.error_4xx_threshold
  alarm_description   = "This metric checks for 4xx errors in the ${each.value.api} API"
  alarm_actions       = [local.sns_topic_arn]
  dimensions = {
    ApiName = each.value.api
  }
}

resource "aws_cloudwatch_metric_alarm" "api_5xx_errors_alarm" {
  for_each = { for idx, api in local.merged_apis : idx => api }

  alarm_name          = "${each.value.api}-5xxErrors"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "5XXError"
  namespace           = "AWS/ApiGateway"
  period              = "300"
  statistic           = "SampleCount"
  threshold           = each.value.error_5xx_threshold
  alarm_description   = "This metric checks for 5xx errors in the ${each.value.api} API"
  alarm_actions       = [local.sns_topic_arn]
  dimensions = {
    ApiName = each.value.api
  }
}

resource "aws_cloudwatch_metric_alarm" "latency_alarm" {
  for_each = { for idx, api in local.merged_apis : idx => api }

  alarm_name          = format("%s-Latency", each.value.api)
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "Latency"
  namespace           = "AWS/ApiGateway"
  period              = "60"
  statistic           = "Average"
  threshold           = each.value.integration_latency_threshold
  alarm_description   = format("Latency threshold exceeded for API %s", each.value.api)
  alarm_actions       = [local.sns_topic_arn]
  dimensions = {
    ApiName = each.value.api
  }
}

resource "aws_cloudwatch_metric_alarm" "integration_latency_alarm" {
  for_each = { for idx, api in local.merged_apis : idx => api }

  alarm_name          = format("%s-IntegrationLatency", each.value.api)
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "IntegrationLatency"
  namespace           = "AWS/ApiGateway"
  period              = "60"
  statistic           = "Average"
  threshold           = each.value.latency_threshold
  alarm_description   = format("Integration latency threshold exceeded for API %s", each.value.api)
  alarm_actions       = [local.sns_topic_arn]
  dimensions = {
    ApiName = each.value.api
  }
}
