# Terraform Module: CloudWatch Alarms

This module sets up all necessary CloudWatch Alarms for the AWS resources provided. It will also create an SNS topic and set it as the target for alarm actions.

In addition, it integrates with terraform-module-cloudwatch-dashboards to create and manage corresponding CloudWatch monitoring dashboards. Alarms are then mapped to their relevant dashboard widgets.
## Usage

To use this module, you need to provide a list of AWS resources that you want to monitor. Here's an example:
(Please note, this is just an example. Resources provided should belong to the same service/system/adapter)

```hcl


module "cloudwatch_alarms" {
  source = "git::https://bitbucket.org/nsw-education/terraform-module-cloudwatch-alarms.git?ref=main"

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
      # If IOPS are set to on-demand, select a total IOPS of 100 and adjust as required
      {
        "rds" : "staff-service-datastore",
        "total-iops": 100,
        "total-memory": 5.34 * 1024 *1024 * 1024, # 5.34 GB
        "total-storage": 418 * 1024 * 1024 * 1024 # 418 GB 
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
}

# terraform-module-cloudwatch-alarms will provide the outputs to be consumed by terraform-module-cloudwatch-dashboards
module "service-dashboard-example" {
  source = "git::https://bitbucket.org/nsw-education/terraform-module-cloudwatch-dashboards.git?ref=main"

  env = module.cloudwatch_alarms.env

  service_name   = module.cloudwatch_alarms.service_name
  
  resource_list  = module.cloudwatch_alarms.resource_list
}

```
