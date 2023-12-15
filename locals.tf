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
  default_eventbridge_thresholds = { for eventbridge in var.resource_list.eventbridges : eventbridge.name => {
    eventbridge_dead_letter_threshold  = 1,
  }}

  merged_eventbridges = [for eventbridge in var.resource_list.eventbridges : {
    name          = eventbridge.name
    ruleName      = eventbridge.ruleName
    eventbridge_dead_letter_threshold  = lookup(var.eventbridge_thresholds, eventbridge.name, local.default_eventbridge_thresholds[eventbridge.name]).eventbridge_dead_letter_threshold
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
  default_rds_thresholds = { for rds in var.resource_list.rdss : rds.rds => {
    total_iops_threshold  = 0.8 * rds.total-iops,
    cpu_utilization_threshold = 80, #%
    read_latency_threshold  = 1 * 0.05, #5 millisecond in seconds
    write_latency_threshold = 1 * 0.1, #10 millisecond in seconds
    freeable_memory_threshold  = 0.2 * rds.total-memory, #Bytes
    free_storage_space_threshold = 0.1 * rds.total-storage #Bytes
  }}

  merged_rds = [for rds in var.resource_list.rdss : {
    rds          = rds.rds
    total-iops      = rds.total-iops
    total-memory     = rds.total-memory
    total-storage     = rds.total-storage
    cpu_utilization_threshold  = lookup(var.rds_thresholds, rds.rds, local.default_rds_thresholds[rds.rds]).cpu_utilization_threshold
    total_iops_threshold = lookup(var.rds_thresholds, rds.rds, local.default_rds_thresholds[rds.rds]).total_iops_threshold
    read_latency_threshold  = lookup(var.rds_thresholds, rds.rds, local.default_rds_thresholds[rds.rds]).read_latency_threshold
    write_latency_threshold = lookup(var.rds_thresholds, rds.rds, local.default_rds_thresholds[rds.rds]).write_latency_threshold
    freeable_memory_threshold  = lookup(var.rds_thresholds, rds.rds, local.default_rds_thresholds[rds.rds]).freeable_memory_threshold
    free_storage_space_threshold = lookup(var.rds_thresholds, rds.rds, local.default_rds_thresholds[rds.rds]).free_storage_space_threshold
  }]
}

locals {
  default_sqs_thresholds = { for queue in var.resource_list.queues : queue.name => {
    sqs_approx_num_messages_visible_threshold  = 100,
    sqs_approx_age_of_oldest_message_threshold  = 300 # seconds
  }}

  merged_sqs = [for sqs in var.resource_list.queues : {
    name          = sqs.name
    sqs_approx_num_messages_visible_threshold  = lookup(var.sqs_thresholds, sqs.name, local.default_sqs_thresholds[sqs.name]).sqs_approx_num_messages_visible_threshold
    sqs_approx_age_of_oldest_message_threshold  = lookup(var.sqs_thresholds, sqs.name, local.default_sqs_thresholds[sqs.name]).sqs_approx_age_of_oldest_message_threshold
  }]
}

locals {
  sns_topic_arn = aws_sns_topic.alarms_topic.arn
}
