resource "aws_sns_topic" "alarms_topic" {
  name = "${var.service_name}-${var.env}-Alarms"
}

locals {
  sns_topic_arn = aws_sns_topic.alarms_topic.arn
}
