locals {
  lambdas = [
    for idx, lambda_obj in local.lambda_list : {
      "lambda" = lambda_obj.lambda,
      "alarms" = [
        {
          "error_alarm_arn" = aws_cloudwatch_metric_alarm.errors_alarm[idx].arn
        },
        {
          "duration_alarm_arn" = aws_cloudwatch_metric_alarm.duration_alarm[idx].arn
        },
        {
          "memory_overuse_alarm_arn" = aws_cloudwatch_metric_alarm.memory_overutilization_alarm[idx].arn
        },
        {
          "memory_underuse_alarm_arn" = aws_cloudwatch_metric_alarm.memory_underutilization_alarm[idx].arn
        },
        {
          "throttles_alarm_arn" = aws_cloudwatch_metric_alarm.throttles_alarm[idx].arn
        },
        {
          "executions_alarm_arn" = aws_cloudwatch_metric_alarm.concurrent_executions_alarm[idx].arn
        },
        {
          "success_rate_alarm_arn" = aws_cloudwatch_metric_alarm.success_rate[idx].arn
        },
      ]
    }
  ]

  rdss = [
    for idx, rds in local.rds_list : {
      "rds" = rds.rds,
      "alarms" = [
        {
          "iops_alarm_arn" = aws_cloudwatch_metric_alarm.total_iops_alarm[idx].arn
        },
        {
          "cpu_alarm_arn" = aws_cloudwatch_metric_alarm.cpu_utilization_alarm[idx].arn
        },
        {
          "read_alarm_arn" = aws_cloudwatch_metric_alarm.read_latency_alarm[idx].arn
        },
        {
          "write_alarm_arn" = aws_cloudwatch_metric_alarm.write_latency_alarm[idx].arn
        },
        {
          "memory_alarm_arn" = aws_cloudwatch_metric_alarm.freeable_memory_alarm[idx].arn
        },
        {
          "storage_alarm_arn" = aws_cloudwatch_metric_alarm.free_storage_space_alarm[idx].arn
        },
      ]
    }
  ]

  apis = [
    for idx, api in local.api_list : {
      "api" = api.api,
      "alarms" = [
        {
          "latency_alarm_arn" = aws_cloudwatch_metric_alarm.latency_alarm[idx].arn
        },
        {
          "integrationlatency_alarm_arn" = aws_cloudwatch_metric_alarm.integration_latency_alarm[idx].arn
        },
        {
          "4xx_errors_alarm_arn" = aws_cloudwatch_metric_alarm.api_4xx_errors_alarm[idx].arn
        },
        {
          "5xx_errors_alarm_arn" = aws_cloudwatch_metric_alarm.api_5xx_errors_alarm[idx].arn
        }
      ]
    }
  ]

  dynamos = [
    for idx, dynamo in local.dynamo_list : {
      "dynamo" = dynamo.dynamo,
      "alarms" = [
        {
          "read_alarm_arn" = aws_cloudwatch_metric_alarm.read_capacity_alarm[idx].arn
        },
        {
          "write_alarm_arn" = aws_cloudwatch_metric_alarm.write_capacity_alarm[idx].arn
        }
      ]
    }
  ]

  eventbridges = [
    for idx, eventbridge in local.eventbridge_list : {
      "eventbridge" = eventbridge.name,
      "alarms" = [
        {
          "eventbridge_dead_letter_alarm" = aws_cloudwatch_metric_alarm.eventbridge_dead_letter_alarm[idx].arn
        }
      ]
    }
  ]

  queues = [
    for idx, queue in local.sqs_list : {
      "queue" = queue.name,
      "alarms" = [
        {
          "sqs_approx_num_messages_visible_alarm" = aws_cloudwatch_metric_alarm.sqs_approx_num_messages_visible_alarm[idx].arn
        },
        {
          "sqs_approx_age_of_oldest_message_alarm" = aws_cloudwatch_metric_alarm.eventbridge_dead_letter_alarm[idx].arn
        }
      ]
    }
  ]
}

output "env" {
  value = var.env
}

output "service_name" {
  value = var.service_name
}

output "resource_list" {
  value = {
    apis         = local.apis,
    eventbridges = local.eventbridges,
    dynamos      = local.dynamos,
    lambdas      = local.lambdas,
    rdss         = local.rdss,
    queues       = local.queues
  }
  description = "List of AWS resources and their required alarm ARNs"
}

output "sns_topic_arn" {
  value = {
    sns_arn = local.sns_topic_arn
  }
  description = "ARN of SNS topic to which alrms will be sent"
}
