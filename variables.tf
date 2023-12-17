variable "service_name" {
  type        = string
  description = "The service name."
}

variable "env" {
  type        = string
  description = "AWS environment"
}

variable "resource_list" {
  description = "List of AWS resources and their required alarm ARNs"
  type = object({
    apis = list(object({
      api = string
    }))
    dynamos = list(object({
      dynamo      = string
      read_units  = number
      write_units = number
    }))
    eventbridges = list(object({
      name     = string
      ruleName = string
    }))
    queues = list(object({
      name = string
    }))
    lambdas = list(object({
      lambda      = string
      timeout     = number
      concurrency = number
      memory      = number
    }))
    rdss = list(object({
      rds           = string
      total-iops    = number
      total-memory  = number
      total-storage = number
    }))
    sns_subscriptions = list(object({
      protocol = string
      endpoint = string
    }))
  })
}

variable "api_thresholds" {
  description = "Thresholds for APIs"
  type = map(object({
    error_4xx_threshold           = number
    error_5xx_threshold           = number
    latency_threshold             = number
    integration_latency_threshold = number
  }))
  default = {}
}

variable "dynamo_thresholds" {
  description = "Thresholds for Dynamo DBs"
  type = map(object({
    read_capacity_threshold  = number
    write_capacity_threshold = number
  }))
  default = {}
}

variable "eventbridge_thresholds" {
  description = "Thresholds for EventBridge rules"
  type = map(object({
    eventbridge_dead_letter_threshold = number
  }))
  default = {}
}

variable "lambda_thresholds" {
  description = "Thresholds for Lambdas"
  type = map(object({
    success_rate_threshold            = number
    errors_threshold                  = number
    duration_threshold                = number
    memory_underutilization_threshold = number
    memory_overutilization_threshold  = number
    concurrent_executions_threshold   = number
    throttles_threshold               = number
  }))
  default = {}
}

variable "rds_thresholds" {
  description = "Thresholds for RDS instances"
  type = map(object({
    total_iops_threshold         = number
    cpu_utilization_threshold    = number
    read_latency_threshold       = number
    write_latency_threshold      = number
    freeable_memory_threshold    = number
    free_storage_space_threshold = number
  }))
  default = {}
}

variable "sqs_thresholds" {
  description = "Thresholds for SQS queues"
  type = map(object({
    sqs_approx_num_messages_visible_threshold  = number
    sqs_approx_age_of_oldest_message_threshold = number
  }))
  default = {}
}

variable "lambda_function_name" {
  type        = string
  description = "The lambda function name for use with CloudWatch Metrics."
  default     = "staff-personal-change-event-processor-lambda"
}

variable "enable_metric_alarm" {
  type        = bool
  description = "Enable the alarm"
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to the alarms."
  default     = {}
}

variable "actions_enabled" {
  type        = bool
  description = "Enable the actions. Set to false to temporarily disable actions."
  default     = true
}

variable "actions_alarm" {
  type        = list(string)
  description = "List of actions to take in alarm state"
  default     = []
}

variable "actions_ok" {
  type        = list(string)
  description = "List of actions to take in healty state"
  default     = []
}

variable "actions_insufficient_data" {
  type        = list(string)
  description = "List of actions to take to take in insufficient data state"
  default     = []
}


variable "threshold" {
  type        = string
  description = "The threshold for the metric alarm"
  default     = "99.5"
}

variable "evaluation_periods" {
  type        = number
  description = "The number of periods over which data is compared to the specified threshold."
  default     = 2
}

variable "period" {
  type        = number
  description = "The period in seconds over which the specified statistic is applied."
  default     = 120
}
