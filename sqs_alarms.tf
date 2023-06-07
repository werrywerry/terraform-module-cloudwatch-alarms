locals {
  sqs_list = [for queue in var.resource_list["queues"] : queue]
}


resource "aws_cloudwatch_metric_alarm" "sqs_approx_num_messages_visible_alarm" {
  for_each = { for idx, queue in local.sqs_list : idx => queue }

  alarm_name          = format("%s-sqs_approx_num_messages_visible_alarm", each.value.queue)
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 300
  statistic           = "SampleCount"
  threshold           = 100 #Number of Messages
  alarm_description   = "This alarm is triggered when the approximate number of messages visible in the SQS queue exceeds 100"

  alarm_actions = [local.sns_topic_arn]

  dimensions = {
    QueueName = each.value.queue
  }
}

resource "aws_cloudwatch_metric_alarm" "sqs_approx_age_of_oldest_message_alarm" {
  for_each = { for idx, queue in local.sqs_list : idx => queue }

  alarm_name          = format("%s-sqs_approx_age_of_oldest_message_alarm", each.value.queue)
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateAgeOfOldestMessage"
  namespace           = "AWS/SQS"
  period              = 300
  statistic           = "SampleCount"
  threshold           = 900 #Seconds

  alarm_description = "This alarm is triggered when the approximate age of the oldest message in the SQS queue exceeds 900 seconds"

  alarm_actions = [local.sns_topic_arn]

  dimensions = {
    QueueName = each.value.queue
  }
}

