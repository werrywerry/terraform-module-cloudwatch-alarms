resource "aws_sns_topic" "alarms_topic" {
  name = "${var.service_name}-${var.env}-Alarms"
}
