resource "aws_cloudwatch_metric_alarm" "eventbridge_dead_letter_alarm" {
  for_each = { for idx, eventbridge in local.eventbridge_list : idx => eventbridge }

  alarm_name          = "${each.value.name}-DeadLetterInvocations"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "DeadLetterInvocations"
  namespace           = "AWS/Events"
  period              = 300
  statistic           = "SampleCount"
  threshold           = 1 #DeadLetterInvocations

  alarm_description = format("This alarm is triggered when there is at least 1 DeadLetterInvocation in EventBridge %s", each.value.name)

  alarm_actions = [local.sns_topic_arn]

  dimensions = {
    RuleName = each.value.ruleName
  }
}