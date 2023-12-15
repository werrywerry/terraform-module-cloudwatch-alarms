resource "aws_cloudwatch_metric_alarm" "total_iops_alarm" {
  for_each = { for idx, rds in local.merged_rds : idx => rds }

  alarm_name          = format("%s-TotalIOPS", each.value.rds)
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  alarm_actions       = [local.sns_topic_arn]
  threshold           = each.value.total_iops_threshold
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
  for_each = { for idx, rds in local.merged_rds : idx => rds }

  alarm_name          = format("%s-CPUUtilization", each.value.rds)
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Maximum"
  threshold           = each.value.cpu_utilization_threshold
  alarm_description   = "CPU utilization threshold exceeded for ${each.value.rds}"
  alarm_actions       = [local.sns_topic_arn]
  dimensions = {
    DBInstanceIdentifier = each.value.rds
  }
}

resource "aws_cloudwatch_metric_alarm" "read_latency_alarm" {
  for_each = { for idx, rds in local.merged_rds : idx => rds }

  alarm_name          = format("%s-ReadLatency", each.value.rds)
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "ReadLatency"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Maximum"
  threshold           = each.value.read_latency_threshold
  alarm_description   = "Read latency threshold exceeded for ${each.value.rds}"
  alarm_actions       = [local.sns_topic_arn]
  dimensions = {
    DBInstanceIdentifier = each.value.rds
  }
}

resource "aws_cloudwatch_metric_alarm" "write_latency_alarm" {
  for_each = { for idx, rds in local.merged_rds : idx => rds }

  alarm_name          = format("%s-WriteLatency", each.value.rds)
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1" 
  metric_name         = "WriteLatency"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Maximum"
  threshold           = each.value.write_latency_threshold
  alarm_description   = "Write latency threshold exceeded for ${each.value.rds}"
  alarm_actions       = [local.sns_topic_arn]
  dimensions = {
    DBInstanceIdentifier = each.value.rds
  }
}

resource "aws_cloudwatch_metric_alarm" "freeable_memory_alarm" {
  for_each = { for idx, rds in local.merged_rds : idx => rds }

  alarm_name          = format("%s-FreeableMemory", each.value.rds)
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "FreeableMemory"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Minimum"
  threshold           = each.value.freeable_memory_threshold
  alarm_description   = "Freeable memory threshold exceeded for ${each.value.rds}"
  alarm_actions       = [local.sns_topic_arn]
  dimensions = {
    DBInstanceIdentifier = each.value.rds
  }
}

resource "aws_cloudwatch_metric_alarm" "free_storage_space_alarm" {
  for_each = { for idx, rds in local.merged_rds : idx => rds }

  alarm_name          = format("%s-FreeStorageSpace", each.value.rds)
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Minimum"
  threshold           = each.value.free_storage_space_threshold
  alarm_description   = "Free storage threshold exceeded for ${each.value.rds}"
  alarm_actions       = [local.sns_topic_arn]
  dimensions = {
    DBInstanceIdentifier = each.value.rds
  }
}
