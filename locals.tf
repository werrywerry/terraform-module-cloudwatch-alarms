locals {
  api_list = [for api in var.resource_list["apis"] : api]
  dynamo_list = [for dynamo in var.resource_list["dynamos"] : dynamo]
  eventbridge_list = [for eventbridge in var.resource_list["eventbridges"] : eventbridge]
  lambda_list = [for lambda_obj in var.resource_list["lambdas"] : lambda_obj]
  rds_list = [for rds in var.resource_list["rdss"] : rds]
  sqs_list = [for queue in var.resource_list["queues"] : queue]
  sns_subscriptions = [for sub in var.resource_list["sns_subscriptions"] : sub]
}

locals {
  default_api_thresholds = {
    error_4xx_threshold            = 5
    error_5xx_threshold            = 2
    latency_threshold              = 1500
    integration_latency_threshold  = 2500
  }
  merged_apis = [for api in var.resource_list.apis : merge(
    {
      api = api.api
    }, 
    local.default_api_thresholds,
    contains(keys(var.api_thresholds), api.api) ? var.api_thresholds[api.api] : {}
  )]
}

locals {
  default_dynamo_thresholds = { for dynamo in var.resource_list.dynamos : dynamo.dynamo => {
    read_capacity_threshold  = 0.8 * dynamo.read_units,
    write_capacity_threshold = 0.8 * dynamo.write_units
  }}

  merged_dynamodb = [for dynamo in var.resource_list.dynamos : {
    dynamo          = dynamo.dynamo
    read_units      = dynamo.read_units
    write_units     = dynamo.write_units
    read_capacity_threshold  = lookup(var.dynamo_thresholds, dynamo.dynamo, local.default_dynamo_thresholds[dynamo.dynamo]).read_capacity_threshold
    write_capacity_threshold = lookup(var.dynamo_thresholds, dynamo.dynamo, local.default_dynamo_thresholds[dynamo.dynamo]).write_capacity_threshold
  }]
}

locals {
  default_lambda_thresholds = { for lambda in var.resource_list.lambdas : lambda.lambda => {
    success_rate_threshold            = 99,   # in %
    errors_threshold                  = 1,
    duration_threshold                = 0.9 * lambda.timeout,
    memory_underutilization_threshold = 0.3 * lambda.memory,
    memory_overutilization_threshold  = 0.8 * lambda.memory,
    concurrent_executions_threshold   = 0.8 * lambda.concurrency,
    throttles_threshold               = 3
  }}

  merged_lambdas = [for lambda in var.resource_list.lambdas : {
    lambda          = lambda.lambda
    concurrency     = lambda.concurrency
    memory          = lambda.memory
    timeout         = lambda.timeout
    success_rate_threshold      = lookup(var.lambda_thresholds, lambda.lambda, local.default_lambda_thresholds[lambda.lambda]).success_rate_threshold
    errors_threshold     = lookup(var.lambda_thresholds, lambda.lambda, local.default_lambda_thresholds[lambda.lambda]).errors_threshold
    duration_threshold     = lookup(var.lambda_thresholds, lambda.lambda, local.default_lambda_thresholds[lambda.lambda]).duration_threshold
    memory_underutilization_threshold  = lookup(var.lambda_thresholds, lambda.lambda, local.default_lambda_thresholds[lambda.lambda]).memory_underutilization_threshold
    memory_overutilization_threshold = lookup(var.lambda_thresholds, lambda.lambda, local.default_lambda_thresholds[lambda.lambda]).memory_overutilization_threshold
    concurrent_executions_threshold     = lookup(var.lambda_thresholds, lambda.lambda, local.default_lambda_thresholds[lambda.lambda]).concurrent_executions_threshold
    throttles_threshold     = lookup(var.lambda_thresholds, lambda.lambda, local.default_lambda_thresholds[lambda.lambda]).throttles_threshold
  }]
}

locals {
  sns_topic_arn = aws_sns_topic.alarms_topic.arn
}
