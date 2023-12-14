resource "aws_cloudwatch_metric_alarm" "read_capacity_alarm" {
  for_each = { for idx, dynamo in local.merged_dynamodb : idx => dynamo }

  alarm_name          = format("%s-ConsumedReadCapacityUnits", each.value.dynamo)
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "ConsumedReadCapacityUnits"
  namespace           = "AWS/DynamoDB"
  period              = "60"
  statistic           = "Average"
  threshold           = each.value.read_threshold
  alarm_description   = format("Read capacity threshold exceeded for DynamoDB table %s", each.value.dynamo)
  alarm_actions       = [local.sns_topic_arn]
  dimensions = {
    TableName = each.value.dynamo
  }
}

resource "aws_cloudwatch_metric_alarm" "write_capacity_alarm" {
  for_each = { for idx, dynamo in local.merged_dynamodb : idx => dynamo }

  alarm_name          = format("%s-ConsumedWriteCapacityUnits", each.value.dynamo)
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "ConsumedWriteCapacityUnits"
  namespace           = "AWS/DynamoDB"
  period              = "60"
  statistic           = "Average"
  threshold           = each.value.write_threshold
  alarm_description   = format("Write capacity threshold exceeded for DynamoDB table %s", each.value.dynamo)
  alarm_actions       = [local.sns_topic_arn]
  dimensions = {
    TableName = each.value.dynamo
  }
}
