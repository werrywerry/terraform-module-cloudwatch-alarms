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
  merged_dynamodb = [for dynamo in var.resource_list.dynamos : {
    dynamo          = dynamo.dynamo
    read_units      = dynamo.read_units
    write_units     = dynamo.write_units
    read_threshold  = lookup(var.dynamo_thresholds, dynamo.dynamo, 
                      { "read_capacity_threshold" = 0.8 * dynamo.read_units }).read_capacity_threshold
    write_threshold = lookup(var.dynamo_thresholds, dynamo.dynamo, 
                      { "write_capacity_threshold" = 0.8 * dynamo.write_units }).write_capacity_threshold
  }]
}

locals {
  sns_topic_arn = aws_sns_topic.alarms_topic.arn
}
