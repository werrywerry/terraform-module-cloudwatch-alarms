resource "aws_cloudwatch_metric_alarm" "sqs_approx_num_messages_visible_alarm" {
  for_each = { for idx, queue in local.merged_sqs : idx => queue }

  alarm_name          = format("%s-sqs_approx_num_messages_visible_alarm", each.value.name)
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 300
  statistic           = "SampleCount"
  threshold           = each.value.sqs_approx_num_messages_visible_threshold
  alarm_description   = "This alarm is triggered when the approximate number of messages visible in the SQS queue exceeds threshold"

  alarm_actions = [local.sns_topic_arn]

  dimensions = {
    QueueName = each.value.name
  }
}

resource "aws_cloudwatch_metric_alarm" "sqs_approx_age_of_oldest_message_alarm" {
  for_each = { for idx, queue in local.merged_sqs : idx => queue }

  alarm_name          = format("%s-sqs_approx_age_of_oldest_message_alarm", each.value.name)
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateAgeOfOldestMessage"
  namespace           = "AWS/SQS"
  period              = 300
  statistic           = "SampleCount"
  threshold           = each.value.sqs_approx_age_of_oldest_message_threshold

  alarm_description = "This alarm is triggered when the approximate age of the oldest message in the SQS queue exceeds threshold"

  alarm_actions = [local.sns_topic_arn]

  dimensions = {
    QueueName = each.value.name
  }
}
