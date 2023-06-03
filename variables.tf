variable "name" {
  type        = string
  description = "The service name."
  default     = "TerraformDashboardDemo"
}

variable "resource_list" {
  description = "List of AWS resources and their required alarm ARNs"
  type = object({
    apis = list(object({
      api    = string
    }))
    dynamos = list(object({
      dynamo = string
    }))
    eventbridges = list(object({
      name = string
      ruleName = string
    }))    
    lambdas = list(object({
      lambda = string
    }))
    rdss = list(object({
      rds    = string
    }))
  })
  default = {
    "lambdas" : [
      { "lambda" : "staff-personal-change-event-processor-lambda" },
    ],
    "rdss" : [
      { "rds" : "staff-service-datastore" }
    ],
    "apis" : [
      { "api" : "staff-service-v3" }
    ],
    "dynamos" : [
      { "dynamo" : "CapabilityDemo-AwsXray" }
    ],
    "eventbridges" : [
      { "name" : "staff-service-event-bus", 
        "ruleName" : "CapabilityDemo-AwsXray" }
    ],
    
  }
}

variable "lambda_function_name" {
  type        = string
  description = "The lambda function name for use with CloudWatch Metrics."
  default = "staff-personal-change-event-processor-lambda"
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
