# Terraform Module: CloudWatch Alarms

This module helps set up all necessary CloudWatch Alarms for the AWS resources provided. In addition, it integrates with `terraform-module-service-dashboards` to create and manage corresponding CloudWatch monitoring dashboards. Alarms are then mapped to their relevant dashboard widgets.

## Usage

To use this module, you need to provide a list of AWS resources that you want to monitor. Here's an example:
(Please note, this is just an example. Resources provided should belong to the same service/system/adapter)

```hcl
module "cloudwatch_alarms" {
  source = "git::https://bitbucket.det.nsw.edu.au/scm/entint/terraform-module-lambda-alarms.git?ref=feature/integrate-with-dashboards"

  resource_list = {
    "lambdas" : [
      { "lambda" : "staff-personal-change-event-processor-lambda" },
      { "lambda" : "staff-personal-location-change-event-processor" },
      { "lambda" : "staff-service-staffpersonal-request-handler-lambda" },
    ],
    "rdss" : [
      { "rds" : "staff-service-datastore" },
      { "rds" : "room-service-datastore" }
    ],
    "apis" : [
      { "api" : "staff-service-v3" },
      { "api" : "room-service-v1" }
    ],
    "dynamos" : [
      { "dynamo" : "PayloadService-PayloadsStore-dev-DynamoDB" },
      { "dynamo" : "CapabilityDemo-AwsXray" }
    ]
  }
}

module "service-dashboard-example" {
  source = "git::https://bitbucket.det.nsw.edu.au/scm/entint/terraform-module-service-dashboard.git?ref=feature/initial"

  env = "dev"
  service_name = "TerraformDashboardDemo"
  resource_list = module.cloudwatch_alarms.resource_list
}
```
