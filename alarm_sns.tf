resource "aws_sns_topic" "alarms_topic" {
  name = "${var.service_name}-${var.env}-Alarms"
}

resource "aws_sns_topic_subscription" "subscription" {
  for_each   = { for idx, sub in local.sns_subscriptions : idx => sub }
  topic_arn  = aws_sns_topic.alarms_topic.arn
  protocol   = each.value.protocol
  endpoint   = each.value.endpoint
}
