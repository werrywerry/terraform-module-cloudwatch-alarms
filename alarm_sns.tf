resource "aws_sns_topic" "alarms_topic" {
  name = var.name
}

locals {
  sns_topic_arn = aws_sns_topic.alarms_topic.arn
}
