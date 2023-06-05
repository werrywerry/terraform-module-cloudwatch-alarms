
locals {
  rds_list    = [for rds in var.resource_list["rdss"] : rds]
}

resource "aws_cloudwatch_metric_alarm" "total_iops_alarm" {
  for_each = { for idx, rds in local.rds_list : idx => rds }

  alarm_name        = format("%s-TotalIOPS", each.value.rds)
  alarm_description = format("80%% of provisioned IOPS usage for %s", each.value.rds)
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "ReadIOPS + WriteIOPS"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "SampleCount"
  threshold           = "1000"
  alarm_actions       = [local.sns_topic_arn]
  dimensions = {
    DBInstanceIdentifier = each.value.rds
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization_alarm" {
  for_each = { for idx, rds in local.rds_list : idx => rds }

  alarm_name        = format("%s-CPUUtilization", each.value.rds)
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "80"
  alarm_description   = "CPU utilization threshold exceeded for ${each.value.rds}"
  alarm_actions       = [local.sns_topic_arn]
  dimensions = {
    DBInstanceIdentifier = each.value.rds
  }
}

resource "aws_cloudwatch_metric_alarm" "read_latency_alarm" {
  for_each = { for idx, rds in local.rds_list : idx => rds }

  alarm_name        = format("%s-ReadLatency", each.value.rds)
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "ReadLatency"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "1"
  alarm_description   = "Read latency threshold exceeded for ${each.value.rds}"
  alarm_actions       = [local.sns_topic_arn]
  dimensions = {
    DBInstanceIdentifier = each.value.rds
  }
}

resource "aws_cloudwatch_metric_alarm" "write_latency_alarm" {
  for_each = { for idx, rds in local.rds_list : idx => rds }

  alarm_name        = format("%s-WriteLatency", each.value.rds)
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "WriteLatency"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "1"
  alarm_description   = "Write latency threshold exceeded for ${each.value.rds}"
  alarm_actions       = [local.sns_topic_arn]
  dimensions = {
    DBInstanceIdentifier = each.value.rds
  }
}

resource "aws_cloudwatch_metric_alarm" "freeable_memory_alarm" {
  for_each = { for idx, rds in local.rds_list : idx => rds }

  alarm_name        = format("%s-FreeableMemory", each.value.rds)
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "FreeableMemory"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Minimum"
  threshold           = "0"
  alarm_description   = "Freeable memory threshold exceeded for ${each.value.rds}"
  alarm_actions       = [local.sns_topic_arn]
  dimensions = {
    DBInstanceIdentifier = each.value.rds
  }
}

resource "aws_cloudwatch_metric_alarm" "free_storage_space_alarm" {
  for_each = { for idx, rds in local.rds_list : idx => rds }

  alarm_name        = format("%s-FreeStorageSpace", each.value.rds)
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Minimum"
  threshold           = "0"
  alarm_description   = "Freeable memory threshold exceeded for ${each.value.rds}"
  alarm_actions       = [local.sns_topic_arn]
  dimensions = {
    DBInstanceIdentifier = each.value.rds
  }
}