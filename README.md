# Terraform Module: CloudWatch Alarms

This module sets up all necessary CloudWatch Alarms for the AWS resources provided. It will also create an SNS topic and set it as the target for alarm actions.

In addition, it integrates with terraform-module-cloudwatch-dashboards to create and manage corresponding CloudWatch monitoring dashboards. Alarms are then mapped to their relevant dashboard widgets.
## Usage

To use this module, you need to provide a list of AWS resources that you want to monitor. Here's an example:
(Please note, this is just an example. Resources provided should belong to the same service/system/adapter)

```hcl


module "cloudwatch_alarms" {
  source = "git::https://bitbucket.det.nsw.edu.au/scm/entint/terraform-module-cloudwatch-alarms.git"

  env = "dev"

  service_name   = "TerraformDashboardAlarmDemo"
  
  resource_list = {
    "lambdas" : [
      {
        "lambda" : "staff-personal-change-event-processor-lambda",
        "timeout" : 3000  #ms
      },
      {
        "lambda" : "staff-personal-location-change-event-processor",
        "timeout" : 3000
      },
      {
        "lambda" : "staff-service-staffpersonal-request-handler-lambda",
        "timeout" : 3000
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
      {
        "rds" : "room-service-datastore" ,
        "total-iops": 1000,
        "total-memory": 5.34 * 1024 *1024 * 1024, # 5.34 GB in Bytes
        "total-storage": 418 * 1024 * 1024 * 1024 # 418 GB in Bytes
      }
    ],
    "apis" : [
      { "api" : "staff-service-v3" },
      { "api" : "room-service-v1" }
    ],
    "dynamos" : [
      # If read/write capacity is set to on-demand, set the read/write units to 100 and adjust as necessary
      {
        "dynamo" : "PayloadService-PayloadsStore-dev-DynamoDB",
        "read_units" : 100,
        "write_units" : 100
      },
      {
        "dynamo" : "CapabilityDemo-AwsXray",
        "read_units" : 100,
        "write_units" : 100
      }
    ],
    "eventbridges" : [
      # Provide the event bus name and rule name for each event bus rule. 
      {
        "name" : "staff-service-event-bus", 
        "ruleName" : "CapabilityDemo-AwsXray"
      }
    ],
    "queues" : [],
    "sns_subscriptions" : [
      protocol        = string
      endpoint        = string
    ]
  }
}

# terraform-module-cloudwatch-alarms will provide the outputs to be consumed by terraform-module-cloudwatch-dashboards
module "service-dashboard-example" {
  source = "git::https://bitbucket.det.nsw.edu.au/scm/entint/terraform-module-cloudwatch-dashboards.git?ref=feature/initial"

  env = module.cloudwatch_alarms.env

  service_name   = module.cloudwatch_alarms.service_name
  
  resource_list  = module.cloudwatch_alarms.resource_listI}


```
