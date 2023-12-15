# Terraform Module: CloudWatch Alarms

This module sets up all necessary CloudWatch Alarms for the AWS resources provided. It will also create an SNS topic and set it as the target for alarm actions.

In addition, it integrates with�terraform-module-cloudwatch-dashboards�to create and manage corresponding CloudWatch monitoring dashboards. Alarms are then mapped to their relevant dashboard widgets.
## Usage

To use this module, you need to provide a list of AWS resources that you want to monitor. Here's an example:
(Please note, this is just an example. Resources provided should belong to the same service/system/adapter)

```hcl

module "cloudwatch_alarms" {
  source = "git::https://bitbucket.org/nsw-education/terraform-module-cloudwatch-alarms.git?ref=release/1.0.0"

  env = "Dev"

  service_name   = "Terraform-DashboardAlarm-Demo"
  
  resource_list = {
    "lambdas" : [
      {
        "lambda" : "SharedComponents-StructuredLogging-Demo",
        "timeout" : 5000, #ms
        "concurrency" : 2,
        "memory" : 128
      },
    ],
    "rdss" : [
      {
        "rds" : "staff-service-datastore",
        "total-iops": 3000,
        "total-memory": 8 * 1024 *1024 * 1024, # 8 GB
        "total-storage": 400 * 1024 * 1024 * 1024 # 400 GB 
      },
    ],
    "apis" : [
      { "api" : "staff-service-v3" },
    ],
    "dynamos" : [
      # If read/write capacity is set to on-demand, set the read/write units to 100 and adjust as necessary
      {
        "dynamo" : "PayloadService-PayloadsStore-dev-DynamoDB",
        "read_units" : 100,
        "write_units" : 100
      },
    ],
    "eventbridges" : [
      # Provide the event bus name and rule name for each event bus rule. 
      {
        "name" : "staff-service-event-bus", 
        "ruleName" : "CapabilityDemo-AwsXray"
      }
    ],
    "queues" : [
      { "name" : "test-event-bus-dlq" }
    ],
    # Subscriptions such as email addresses will need to be verified after deployment
    "sns_subscriptions" : [
      {
        "protocol" : "email",
        "endpoint" : "joel.bradley3@det.nsw.edu.au"
      }
    ]
  }
  # THRESHOLD OVERRIDES HERE
}

# terraform-module-cloudwatch-alarms will provide the outputs to be consumed by terraform-module-cloudwatch-dashboards
module "service-dashboard-example" {
  source = "git::https://bitbucket.org/nsw-education/terraform-module-cloudwatch-dashboards.git?ref=release/1.0.0"

  env = module.cloudwatch_alarms.env

  service_name   = module.cloudwatch_alarms.service_name
  
  resource_list  = module.cloudwatch_alarms.resource_list
}

```

**Providing overrides for the alarm threshold defaults**
If no threshold overrides are provided, the module will assign default thresholds to the alarm based on the input variables.
Default alarm threshold values can be found at https://nsw-education.atlassian.net/wiki/spaces/CIA/pages/114859553/Default+Alarm+Thresholds

```hcl
# Assigning override alarm thresholds
# If any alarm thresholds are overridden, values for all the thresholds will need to be assigned
# either a number or null. Null thresholds will use default values
# The following should go inside the "resource_list" block

  
  api_thresholds = {
    "StudentGrade-Api-Dev-ApiGw-V1" = {
      error_4xx_threshold           = 7
      error_5xx_threshold           = 3
      latency_threshold             = null
      integration_latency_threshold = 2800
    }
  }
  dynamo_thresholds = {
    "terraform_locks" = {
      read_capacity_threshold  = null
      write_capacity_threshold = 100
    }
  }

  eventbridge_thresholds = {
    "default" = {
      eventbridge_dead_letter_threshold  = null
    }
  }

  lambda_thresholds = {
    "LoggingService-SubscriptionFilterHandler-Dev" = {
      success_rate_threshold  = null
      errors_threshold = 5
      duration_threshold  = null
      memory_underutilization_threshold = 128
      memory_overutilization_threshold  = 20
      concurrent_executions_threshold = 6
      throttles_threshold  = 7
    }
  }

  rds_thresholds = {
    "staff-service-datastore" = {
      total_iops_threshold  = 500
      cpu_utilization_threshold = null
      read_latency_threshold  = 1
      write_latency_threshold = 2
      freeable_memory_threshold  = null
      free_storage_space_threshold = null
    }
  }

  sqs_thresholds = {
    "room-change-event-to-processor-dlq" = {
      sqs_approx_num_messages_visible_threshold  = 5
      sqs_approx_age_of_oldest_message_threshold  = null
    }
  }
```