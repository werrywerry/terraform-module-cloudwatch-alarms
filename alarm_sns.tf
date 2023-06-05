resource "aws_sns_topic" "alarms_topic" {
  name = "${local.service_name}-Alarms"
}

locals {
  sns_topic_arn = aws_sns_topic.alarms_topic.arn
}
