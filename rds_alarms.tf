
locals {
  rds_list = [for rds in var.resource_list["rdss"] : rds]
}

resource "aws_cloudwatch_metric_alarm" "total_iops_alarm" {
  for_each = { for idx, rds in local.rds_list : idx => rds }

  alarm_name          = format("%s-TotalIOPS", each.value.rds)
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  alarm_actions       = [local.sns_topic_arn]
  threshold           = 0.8 * each.value.total-iops #Total IOPS
  alarm_description   = "Total IOPS threshold exceeded for ${each.value.rds}"

  metric_query {
    id          = "total_iops"
    expression  = "m1 + m2"
    label       = "TotalIOPS"
    return_data = true
  }

  metric_query {
    id = "m1"
    metric {
      metric_name = "ReadIOPS"
      namespace   = "AWS/RDS"
      period      = "60"
      stat        = "SampleCount"
      unit        = "Count"
      dimensions = {
        DBInstanceIdentifier = each.value.rds
      }
    }
  }

  metric_query {
    id = "m2"
    metric {
      metric_name = "WriteIOPS"
      namespace   = "AWS/RDS"
      period      = "60"
      stat        = "SampleCount"
      unit        = "Count"
      dimensions = {
        DBInstanceIdentifier = each.value.rds
      }
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization_alarm" {
  for_each = { for idx, rds in local.rds_list : idx => rds }

  alarm_name          = format("%s-CPUUtilization", each.value.rds)
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "80" #% CPU Usage
  alarm_description   = "CPU utilization threshold exceeded for ${each.value.rds}"
  alarm_actions       = [local.sns_topic_arn]
  dimensions = {
    DBInstanceIdentifier = each.value.rds
  }
}

resource "aws_cloudwatch_metric_alarm" "read_latency_alarm" {
  for_each = { for idx, rds in local.rds_list : idx => rds }

  alarm_name          = format("%s-ReadLatency", each.value.rds)
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "ReadLatency"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Maximum"
  threshold           = 1 * 0.05 #5 millisecond in seconds
  alarm_description   = "Read latency threshold exceeded for ${each.value.rds}"
  alarm_actions       = [local.sns_topic_arn]
  dimensions = {
    DBInstanceIdentifier = each.value.rds
  }
}

resource "aws_cloudwatch_metric_alarm" "write_latency_alarm" {
  for_each = { for idx, rds in local.rds_list : idx => rds }

  alarm_name          = format("%s-WriteLatency", each.value.rds)
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1" 
  metric_name         = "WriteLatency"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Maximum"
  threshold           = 1 * 0.1 #10 millisecond in seconds
  alarm_description   = "Write latency threshold exceeded for ${each.value.rds}"
  alarm_actions       = [local.sns_topic_arn]
  dimensions = {
    DBInstanceIdentifier = each.value.rds
  }
}

resource "aws_cloudwatch_metric_alarm" "freeable_memory_alarm" {
  for_each = { for idx, rds in local.rds_list : idx => rds }

  alarm_name          = format("%s-FreeableMemory", each.value.rds)
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "FreeableMemory"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Minimum"
  threshold           = 0.2 * each.value.total-memory #Bytes
  alarm_description   = "Freeable memory threshold exceeded for ${each.value.rds}"
  alarm_actions       = [local.sns_topic_arn]
  dimensions = {
    DBInstanceIdentifier = each.value.rds
  }
}

resource "aws_cloudwatch_metric_alarm" "free_storage_space_alarm" {
  for_each = { for idx, rds in local.rds_list : idx => rds }

  alarm_name          = format("%s-FreeStorageSpace", each.value.rds)
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Minimum"
  threshold           = 0.1 * each.value.total-storage #Bytes
  alarm_description   = "Free storage threshold exceeded for ${each.value.rds}"
  alarm_actions       = [local.sns_topic_arn]
  dimensions = {
    DBInstanceIdentifier = each.value.rds
  }
}
