locals {
  dynamo_list = [for dynamo in var.resource_list["dynamos"] : dynamo]
}

resource "aws_cloudwatch_metric_alarm" "read_capacity_alarm" {
  for_each = { for idx, dynamo in local.dynamo_list : idx => dynamo }

  alarm_name          = format("%s-ConsumedReadCapacityUnits", each.value.dynamo)
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "ConsumedReadCapacityUnits"
  namespace           = "AWS/DynamoDB"
  period              = "60"
  statistic           = "Sum"
  threshold           = 0.8 * each.value.read_units
  alarm_description   = format("Read capacity threshold exceeded for DynamoDB table %s", each.value.dynamo)
  alarm_actions       = [local.sns_topic_arn]
  dimensions = {
    TableName = each.value.dynamo
  }
}

resource "aws_cloudwatch_metric_alarm" "write_capacity_alarm" {
  for_each = { for idx, dynamo in local.dynamo_list : idx => dynamo }

  alarm_name          = format("%s-ConsumedWriteCapacityUnits", each.value.dynamo)
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "ConsumedWriteCapacityUnits"
  namespace           = "AWS/DynamoDB"
  period              = "60"
  statistic           = "Sum"
  threshold           = 0.8 * each.value.read_units
  alarm_description   = format("Write capacity threshold exceeded for DynamoDB table %s", each.value.dynamo)
  alarm_actions       = [local.sns_topic_arn]
  dimensions = {
    TableName = each.value.dynamo
  }
}
