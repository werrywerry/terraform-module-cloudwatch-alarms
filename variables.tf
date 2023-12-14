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
      api                           = string
      error_4xx_threshold           = number
      error_5xx_threshold           = number
      latency_threshold             = number
      integration_latency_threshold = number
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
  default = {
    apis              = [],
    dynamos           = [],
    eventbridges      = [],
    queues            = [],
    lambdas           = [],
    rdss              = [],
    sns_subscriptions = [],
  }
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
