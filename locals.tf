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
  merged_apis = [for api in var.resource_list.apis : merge(local.default_api_thresholds, { 
    api                            = api.api,
    error_4xx_threshold            = api.error_4xx_threshold != null ? api.error_4xx_threshold : local.default_api_thresholds.error_4xx_threshold,
    error_5xx_threshold            = api.error_5xx_threshold != null ? api.error_5xx_threshold : local.default_api_thresholds.error_5xx_threshold,
    latency_threshold              = api.latency_threshold != null ? api.latency_threshold : local.default_api_thresholds.latency_threshold,
    integration_latency_threshold  = api.integration_latency_threshold != null ? api.integration_latency_threshold : local.default_api_thresholds.integration_latency_threshold
  })]
}


locals {
  sns_topic_arn = aws_sns_topic.alarms_topic.arn
}
