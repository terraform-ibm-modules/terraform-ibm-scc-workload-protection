# RT CSPM (Real-Time Cloud Security Posture Management)

This submodule creates the infrastructure required for streaming configuration changes from an App Configuration config aggregator to IBM Cloud Security and Compliance Center Workload Protection for Real-Time Cloud Security Posture Management (RT CSPM).

## Architecture

The module sets up an end-to-end pipeline:

1. **Activity Tracker → App Configuration**: Routes activity events to the App Configuration config aggregator through an `app_config` target and route
2. **App Configuration → Event Notifications**: A topic filters config-aggregator change events
3. **Event Notifications → COS**: A COS destination and subscription write the notifications to a bucket
4. **COS → Code Engine**: Triggers a Code Engine app on bucket write events
5. **Code Engine App**: Forwards events to the SCC Workload Protection ingestion endpoint
6. **SCC-WP**: Analyzes events and reports configuration changes in real time

The module also enables real-time collection (`realtime_config_enabled = true`) on the App Configuration aggregator settings.

## Modes

| Mode | `use_cdr_infrastructure` | What the module creates |
|---|---|---|
| **Standalone** | `false` (default) | Activity Tracker target and route, Event Notifications topic, destination and subscription, a COS instance and bucket, an IAM Service ID and API key, a trusted profile, a Code Engine project and app, the COS event subscription, and the enablement call on the Workload Protection instance. |
| **With CDR** | `true` | Only the Activity Tracker target and route, the service-to-service authorization policies, and the Event Notifications topic, destination and subscription. Event Notifications writes into the CDR COS bucket. The Service ID, trusted profile, Code Engine project and app, COS subscription and enablement are provided by the [CDR submodule](../cdr). |

When `use_cdr_infrastructure` is `true`, you must also set `cdr_cos_instance_guid`, `cdr_cos_bucket_name` and `cdr_cos_s3_endpoint`. The `cos_*`, `iam_*`, `trusted_profile_name` and `ce_*` inputs are ignored in that mode.

## Prerequisites

- IBM Cloud CLI installed and authenticated
- IBM Cloud Code Engine CLI plugin installed (`ibmcloud ce version`)
- Existing SCC Workload Protection instance with trusted profile and CSPM enabled
- Existing App Configuration instance with the configuration aggregator enabled and a trusted profile configured. The plan fails with a clear message if it is not.
- Existing Event Notifications instance that the App Configuration instance is integrated with

## Aggregator settings

The module manages the `ibm_config_aggregator_settings` resource of the App Configuration instance passed in `app_config_crn`. An instance has only one set of aggregator settings. If another Terraform configuration manages the same settings without also setting `realtime_config_enabled = true`, the two will conflict, and applying the other configuration turns real-time collection off.

## IBM Cloud API key

The COS event subscription is created and deleted by a local script, which uses `ibmcloud_api_key`. The key is kept in the triggers of the `terraform_data` resource so that it is available when the resource is destroyed. It is marked sensitive in plan output, but it is stored in plain text in the Terraform state file. Protect the state accordingly. Changing the key replaces the subscription.

## COS endpoint type and execution environment

The `management_endpoint_type_for_bucket` variable defines the type of endpoint for the IBM Terraform provider to manage the bucket. Possible values are `public`, `private`, or `direct`. The correct value depends on where Terraform is executed.

| Execution environment | Recommended value | Notes |
|---|---|---|
| **IBM Cloud Schematics (shared, multi-tenant)** | `public` or `direct` | Schematics workspaces run on shared infrastructure that reaches COS over the public or direct network. `direct` avoids public-internet egress charges. |
| **IBM Cloud Schematics Agent** with a VPE gateway | `private` | A [Schematics Agent](https://cloud.ibm.com/docs/schematics?topic=schematics-agent-about-overview) deployed inside your VPC, combined with a [Virtual Private Endpoint (VPE) gateway](https://cloud.ibm.com/docs/vpc?topic=vpc-about-vpe) for COS, is required to reach the private endpoint. Without both, Terraform will fail to resolve the private hostname. |
| **Local workstation / CI runner (public internet)** | `public` | Use the public endpoint when running Terraform outside IBM Cloud. |

This setting only applies in standalone mode. In CDR mode the CDR submodule manages the bucket.

### Usage

```hcl
module "rt_cspm" {
  source  = "terraform-ibm-modules/scc-workload-protection/ibm//modules/rt_cspm"
  version = "X.X.X" # Replace with a release version

  # IBM Cloud Authentication
  ibmcloud_api_key = "xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX" #pragma: allowlist secret

  # Basic Configuration
  region            = "us-south"
  resource_group_id = "xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX"
  resource_tags     = ["rt-cspm-tag"]

  # App Configuration (config aggregator must be enabled)
  app_config_crn = "crn:v1:bluemix:public:apprapp:us-south:a/xxxx:xxxx::"

  # Event Notifications
  event_notifications_crn               = "crn:v1:bluemix:public:event-notifications:us-south:a/xxxx:xxxx::"
  event_notifications_topic_name        = "rt-cspm-topic"
  event_notifications_destination_name  = "rt-cspm-cos-destination"
  event_notifications_subscription_name = "rt-cspm-cos-subscription"

  # Activity Tracker
  atracker_target_name = "rt-cspm-at-target"
  atracker_route_name  = "rt-cspm-at-route"

  # Cloud Object Storage
  cos_instance_name = "rt-cspm-cos-instance"
  cos_bucket_name   = "rt-cspm-events-bucket"

  # IAM Service ID and Trusted Profile
  iam_service_id_name  = "rt-cspm-service-id"
  trusted_profile_name = "rt-cspm-trusted-profile"

  # SCC Workload Protection
  target_account_id        = "xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX"
  sysdig_environment_url   = "us-south.security-compliance-secure.cloud.ibm.com"
  workload_protection_crn  = "crn:v1:bluemix:public:sysdig-secure:us-south:a/xxxx:xxxx::"
  workload_protection_guid = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

  # Code Engine
  ce_project_name = "rt-cspm-code-engine-project"
}
```

### Required IAM access policies

You need the following permissions to run this module:

- Account Management
  - **IAM Identity Service** service
      - `Administrator` platform access - Required to create Service IDs, API keys, and Trusted Profiles
  - **IAM Access Management** service
      - `Administrator` platform access - Required to create IAM policies and service-to-service authorizations

- IBM Cloud Services
  - **Activity Tracker Event Routing** service
      - `Editor` or `Administrator` platform access - Required to create Activity Tracker targets and routes
  - **App Configuration** service
      - `Manager` service access - Required to update the config aggregator settings
  - **Event Notifications** service
      - `Manager` service access - Required to create topics, destinations and subscriptions
  - **Cloud Object Storage** service
      - `Manager` service access - Required to create and manage COS instances and buckets
  - **Code Engine** service
      - `Editor` or `Manager` service access - Required to create Code Engine projects, apps, and subscriptions
  - **Container Registry** service
      - `Reader` service access - Required for Code Engine to pull the RT CSPM application image
  - **IBM Cloud Security and Compliance Center Workload Protection** service
      - `Editor` or `Administrator` platform access - Required to configure and manage Workload Protection instances

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 2.9.0, <3.0.0 |
| <a name="requirement_restapi"></a> [restapi](#requirement\_restapi) | >=2.0.1, <3.0.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.9.1, < 1.0.0 |

### Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_app_config_crn_parser"></a> [app\_config\_crn\_parser](#module\_app\_config\_crn\_parser) | terraform-ibm-modules/common-utilities/ibm//modules/crn-parser | 1.9.0 |
| <a name="module_code_engine_app"></a> [code\_engine\_app](#module\_code\_engine\_app) | terraform-ibm-modules/code-engine/ibm//modules/app | 4.9.20 |
| <a name="module_code_engine_project"></a> [code\_engine\_project](#module\_code\_engine\_project) | terraform-ibm-modules/code-engine/ibm | 4.9.20 |
| <a name="module_cos"></a> [cos](#module\_cos) | terraform-ibm-modules/cos/ibm | 11.2.8 |
| <a name="module_event_notification_crn_parser"></a> [event\_notification\_crn\_parser](#module\_event\_notification\_crn\_parser) | terraform-ibm-modules/common-utilities/ibm//modules/crn-parser | 1.9.0 |
| <a name="module_rt_cspm_service_id"></a> [rt\_cspm\_service\_id](#module\_rt\_cspm\_service\_id) | terraform-ibm-modules/iam-service-id/ibm | 1.3.1 |
| <a name="module_rt_cspm_trusted_profile"></a> [rt\_cspm\_trusted\_profile](#module\_rt\_cspm\_trusted\_profile) | terraform-ibm-modules/trusted-profile/ibm | 4.2.0 |

### Resources

| Name | Type |
| ---- | ---- |
| [ibm_atracker_route.rt_cspm](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/atracker_route) | resource |
| [ibm_atracker_target.appconfig](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/atracker_target) | resource |
| [ibm_config_aggregator_settings.config_aggregator_settings_instance](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/config_aggregator_settings) | resource |
| [ibm_en_destination_cos.cos](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/en_destination_cos) | resource |
| [ibm_en_subscription_cos.cos](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/en_subscription_cos) | resource |
| [ibm_en_topic.rt_cspm](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/en_topic) | resource |
| [ibm_iam_authorization_policy.atracker_to_appconfig](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/iam_authorization_policy) | resource |
| [ibm_iam_authorization_policy.ce_to_cos](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/iam_authorization_policy) | resource |
| [ibm_iam_authorization_policy.en_to_cos](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/iam_authorization_policy) | resource |
| [ibm_iam_trusted_profile_identity.service_id](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/iam_trusted_profile_identity) | resource |
| [restapi_object.cdr](https://registry.terraform.io/providers/Mastercard/restapi/latest/docs/resources/object) | resource |
| [terraform_data.install_required_binaries](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [terraform_data.rt_cspm_cos_subscription](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [time_sleep.wait_for_atracker_target_propagation](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [time_sleep.wait_for_atracker_to_appconfig_auth_policy](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [time_sleep.wait_for_en_to_cos_auth_policy](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [ibm_config_aggregator_settings.config_aggregator_settings](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/data-sources/config_aggregator_settings) | data source |

### Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_app_config_crn"></a> [app\_config\_crn](#input\_app\_config\_crn) | The CRN of an existing App Config instance to use with the SCC Workload Protection instance. Required if `cspm_enabled` is true. NOTE: Ensure the App Config instance has configuration aggregator enabled. | `string` | n/a | yes |
| <a name="input_atracker_locations"></a> [atracker\_locations](#input\_atracker\_locations) | List of locations to route Activity Tracker events from. Use ['*'] for all locations. Ensure that the route rule includes the `global` location in addition to your deployment region. | `list(string)` | <pre>[<br/>  "global",<br/>  "*"<br/>]</pre> | no |
| <a name="input_atracker_route_name"></a> [atracker\_route\_name](#input\_atracker\_route\_name) | Name of the Activity Tracker route. | `string` | n/a | yes |
| <a name="input_atracker_target_name"></a> [atracker\_target\_name](#input\_atracker\_target\_name) | Name of the Activity Tracker target. | `string` | n/a | yes |
| <a name="input_cdr_cos_bucket_name"></a> [cdr\_cos\_bucket\_name](#input\_cdr\_cos\_bucket\_name) | Name of the CDR COS bucket that Event Notifications will write to. Required when use\_cdr\_infrastructure is true. | `string` | `null` | no |
| <a name="input_cdr_cos_instance_guid"></a> [cdr\_cos\_instance\_guid](#input\_cdr\_cos\_instance\_guid) | GUID of the COS instance that holds the CDR bucket. Required when use\_cdr\_infrastructure is true. | `string` | `null` | no |
| <a name="input_cdr_cos_s3_endpoint"></a> [cdr\_cos\_s3\_endpoint](#input\_cdr\_cos\_s3\_endpoint) | S3 endpoint of the CDR COS bucket (without https://). Required when use\_cdr\_infrastructure is true. | `string` | `null` | no |
| <a name="input_ce_api_secret_name"></a> [ce\_api\_secret\_name](#input\_ce\_api\_secret\_name) | The name of the secret for the Code Engine application. | `string` | `"rt-cspm-api-secret"` | no |
| <a name="input_ce_app_cpu"></a> [ce\_app\_cpu](#input\_ce\_app\_cpu) | CPU limit for Code Engine app | `string` | `"0.125"` | no |
| <a name="input_ce_app_max_scale"></a> [ce\_app\_max\_scale](#input\_ce\_app\_max\_scale) | Maximum number of instances for Code Engine app | `number` | `10` | no |
| <a name="input_ce_app_memory"></a> [ce\_app\_memory](#input\_ce\_app\_memory) | Memory limit for Code Engine app | `string` | `"500M"` | no |
| <a name="input_ce_app_min_scale"></a> [ce\_app\_min\_scale](#input\_ce\_app\_min\_scale) | Minimum number of instances for Code Engine app. Set to 1 to ensure the app is always ready to receive Object Storage events. | `number` | `1` | no |
| <a name="input_ce_app_name"></a> [ce\_app\_name](#input\_ce\_app\_name) | The name of the Code Engine application for RT CSPM. | `string` | `"ce-rt-cspm-app"` | no |
| <a name="input_ce_app_timeout"></a> [ce\_app\_timeout](#input\_ce\_app\_timeout) | Request timeout in seconds for Code Engine app | `number` | `60` | no |
| <a name="input_ce_icr_secret_name"></a> [ce\_icr\_secret\_name](#input\_ce\_icr\_secret\_name) | The name of the secret for pulling images from Container Registry. | `string` | `"rt-cspm-icr-secret"` | no |
| <a name="input_ce_project_name"></a> [ce\_project\_name](#input\_ce\_project\_name) | The name of the Code Engine project for RT CSPM. Not used when existing\_ce\_project\_id is set. | `string` | `null` | no |
| <a name="input_ce_run_service_account"></a> [ce\_run\_service\_account](#input\_ce\_run\_service\_account) | The name of the service account. | `string` | `"default"` | no |
| <a name="input_cos_bucket_name"></a> [cos\_bucket\_name](#input\_cos\_bucket\_name) | Name of the COS bucket to be used as target for Activity Tracker Event Routing events | `string` | n/a | yes |
| <a name="input_cos_bucket_storage_class"></a> [cos\_bucket\_storage\_class](#input\_cos\_bucket\_storage\_class) | Storage class for the COS bucket. | `string` | `"smart"` | no |
| <a name="input_cos_instance_name"></a> [cos\_instance\_name](#input\_cos\_instance\_name) | Name of the COS instance to be used as target for Activity Tracker Event Routing events. | `string` | `"rt-cspm-cos-instance"` | no |
| <a name="input_cos_plan"></a> [cos\_plan](#input\_cos\_plan) | Plan for the COS instance. | `string` | `"standard"` | no |
| <a name="input_enable_topic_rule"></a> [enable\_topic\_rule](#input\_enable\_topic\_rule) | Whether to enable the rule on the Event Notifications topic source. | `bool` | `true` | no |
| <a name="input_event_notifications_crn"></a> [event\_notifications\_crn](#input\_event\_notifications\_crn) | The CRN of the existing Event Notifications instance to enable notifications for your App Configuration instance. | `string` | n/a | yes |
| <a name="input_event_notifications_destination_name"></a> [event\_notifications\_destination\_name](#input\_event\_notifications\_destination\_name) | The name of the Event Notifications COS destination. | `string` | n/a | yes |
| <a name="input_event_notifications_subscription_name"></a> [event\_notifications\_subscription\_name](#input\_event\_notifications\_subscription\_name) | The name of the Event Notifications COS subscription. | `string` | n/a | yes |
| <a name="input_event_notifications_topic_name"></a> [event\_notifications\_topic\_name](#input\_event\_notifications\_topic\_name) | The name of the Event Notifications topic to route App Configuration aggregator events. | `string` | n/a | yes |
| <a name="input_event_type_filter"></a> [event\_type\_filter](#input\_event\_type\_filter) | Event type filter for the Event Notifications topic rule. | `string` | `"$.*"` | no |
| <a name="input_existing_ce_project_id"></a> [existing\_ce\_project\_id](#input\_existing\_ce\_project\_id) | ID of an existing Code Engine project to reuse (e.g. from the CDR module). When set, no new project is created. | `string` | `null` | no |
| <a name="input_existing_cos_instance_id"></a> [existing\_cos\_instance\_id](#input\_existing\_cos\_instance\_id) | Existing COS instance to pass in. If set to `null`, a new instance will be created. | `string` | `null` | no |
| <a name="input_existing_service_id"></a> [existing\_service\_id](#input\_existing\_service\_id) | ID of an existing IAM Service ID to reuse (e.g. from the CDR module). When set, no new Service ID is created. | `string` | `null` | no |
| <a name="input_existing_service_id_apikey"></a> [existing\_service\_id\_apikey](#input\_existing\_service\_id\_apikey) | API key of the existing Service ID to reuse (e.g. from the CDR module). Required when existing\_service\_id is set. | `string` | `null` | no |
| <a name="input_existing_trusted_profile_id"></a> [existing\_trusted\_profile\_id](#input\_existing\_trusted\_profile\_id) | ID of an existing trusted profile to reuse (e.g. from the CDR module). When set, no new trusted profile is created. | `string` | `null` | no |
| <a name="input_iam_service_id_name"></a> [iam\_service\_id\_name](#input\_iam\_service\_id\_name) | Name of the Service ID for the Code Engine application to send events to Workload Protection instance. Not used when existing\_service\_id is set. | `string` | `null` | no |
| <a name="input_iam_service_policy_name"></a> [iam\_service\_policy\_name](#input\_iam\_service\_policy\_name) | Name of the IAM Service policy having reader access for Container Registry. Not used when existing\_service\_id is set. | `string` | `"container-registry-reader"` | no |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud\_api\_key](#input\_ibmcloud\_api\_key) | IBM Cloud API key for authenticating with IBM Cloud services | `string` | n/a | yes |
| <a name="input_install_required_binaries"></a> [install\_required\_binaries](#input\_install\_required\_binaries) | When set to true, a script will run to check if `jq`, the `ibmcloud` CLI, and the `code-engine` plugin exist on the runtime and if not attempt to download them from the public internet and install them to /tmp. Set to false to skip running this script. | `bool` | `true` | no |
| <a name="input_kms_encryption_enabled"></a> [kms\_encryption\_enabled](#input\_kms\_encryption\_enabled) | Enable KMS encryption for the COS bucket | `bool` | `false` | no |
| <a name="input_kms_key_crn"></a> [kms\_key\_crn](#input\_kms\_key\_crn) | CRN of the KMS key to use for bucket encryption. Required if kms\_encryption\_enabled is true | `string` | `null` | no |
| <a name="input_management_endpoint_type_for_bucket"></a> [management\_endpoint\_type\_for\_bucket](#input\_management\_endpoint\_type\_for\_bucket) | The type of endpoint for the IBM terraform provider to manage the bucket. Possible values are `public`, `private`, or `direct`. | `string` | `"public"` | no |
| <a name="input_notification_filter"></a> [notification\_filter](#input\_notification\_filter) | Notification filter JSONPath regex pattern for filtering App Configuration aggregator events. | `string` | `"$.type =~ 'com.ibm.cloud.apprapp.config_aggregator.*'"` | no |
| <a name="input_region"></a> [region](#input\_region) | IBM Cloud region where RT CSPM resources will be deployed | `string` | `"us-south"` | no |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | The resource group ID in which RT CSPM resources will be provisioned | `string` | n/a | yes |
| <a name="input_resource_tags"></a> [resource\_tags](#input\_resource\_tags) | Optional list of tags to be added to RT CSPM resources | `list(string)` | `[]` | no |
| <a name="input_rt_cspm_ce_app_image"></a> [rt\_cspm\_ce\_app\_image](#input\_rt\_cspm\_ce\_app\_image) | The RT CSPM notification application image hosted in IBM Cloud Container Registry. | `string` | `"icr.io/ext/sysdig/cdr-notification-app:latest"` | no |
| <a name="input_skip_iam_authorization_policy"></a> [skip\_iam\_authorization\_policy](#input\_skip\_iam\_authorization\_policy) | Set to true to skip the creation of an IAM authorization policy that permits the COS instance to read the encryption key from the KMS instance | `bool` | `true` | no |
| <a name="input_subscription_name"></a> [subscription\_name](#input\_subscription\_name) | The name of the COS event subscription to code engine. | `string` | `"rt-cspm-cos-ce-subscription"` | no |
| <a name="input_sysdig_environment_url"></a> [sysdig\_environment\_url](#input\_sysdig\_environment\_url) | The sysdig workload protection environment URL (e.g. 'us-south.security-compliance-secure.cloud.ibm.com'). | `string` | n/a | yes |
| <a name="input_target_account_id"></a> [target\_account\_id](#input\_target\_account\_id) | The IBM Cloud account ID whose auditing events are being forwarded via Activity Tracker Event Routing. | `string` | n/a | yes |
| <a name="input_trusted_profile_name"></a> [trusted\_profile\_name](#input\_trusted\_profile\_name) | The trusted profile for Workload Protection interaction with cloud object storage bucket. Not used when existing\_trusted\_profile\_id is set. | `string` | `null` | no |
| <a name="input_use_cdr_infrastructure"></a> [use\_cdr\_infrastructure](#input\_use\_cdr\_infrastructure) | Set to true when CDR is deployed alongside RT CSPM. RT CSPM then only creates the Activity Tracker and Event Notifications resources, and reuses CDR's COS bucket, Service ID, trusted profile, Code Engine project and app, COS subscription and CDR enablement. Must be known at plan time. | `bool` | `false` | no |
| <a name="input_workload_protection_crn"></a> [workload\_protection\_crn](#input\_workload\_protection\_crn) | The CRN of the SCC Workload Protection instance for trusted profile identity. | `string` | n/a | yes |
| <a name="input_workload_protection_guid"></a> [workload\_protection\_guid](#input\_workload\_protection\_guid) | The GUID of the SCC Workload Protection instance for trusted profile identity. | `string` | n/a | yes |

### Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_atracker_route_id"></a> [atracker\_route\_id](#output\_atracker\_route\_id) | ID of the Activity Tracker route |
| <a name="output_atracker_target_crn"></a> [atracker\_target\_crn](#output\_atracker\_target\_crn) | CRN of the Activity Tracker target |
| <a name="output_atracker_target_id"></a> [atracker\_target\_id](#output\_atracker\_target\_id) | ID of the Activity Tracker target that delivers events to App Configuration |
| <a name="output_code_engine_app"></a> [code\_engine\_app](#output\_code\_engine\_app) | Name of the Code Engine app that forwards RT CSPM events. Null when CDR infrastructure is used. |
| <a name="output_code_engine_app_url"></a> [code\_engine\_app\_url](#output\_code\_engine\_app\_url) | URL of the Code Engine app. Null when CDR infrastructure is used. |
| <a name="output_code_engine_project_id"></a> [code\_engine\_project\_id](#output\_code\_engine\_project\_id) | ID of the Code Engine project used by RT CSPM. Null when CDR infrastructure is used. |
| <a name="output_cos_bucket_crn"></a> [cos\_bucket\_crn](#output\_cos\_bucket\_crn) | CRN of the COS bucket created by RT CSPM. Null when CDR infrastructure is used. |
| <a name="output_cos_bucket_id"></a> [cos\_bucket\_id](#output\_cos\_bucket\_id) | ID of the COS bucket created by RT CSPM. Null when CDR infrastructure is used. |
| <a name="output_cos_bucket_name"></a> [cos\_bucket\_name](#output\_cos\_bucket\_name) | Name of the COS bucket that stores RT CSPM notification archives (the CDR bucket when CDR infrastructure is used) |
| <a name="output_cos_instance_crn"></a> [cos\_instance\_crn](#output\_cos\_instance\_crn) | CRN of the COS instance created by RT CSPM. Null when CDR infrastructure is used. |
| <a name="output_cos_instance_guid"></a> [cos\_instance\_guid](#output\_cos\_instance\_guid) | GUID of the COS instance that stores RT CSPM notification archives (the CDR instance when CDR infrastructure is used) |
| <a name="output_cos_instance_id"></a> [cos\_instance\_id](#output\_cos\_instance\_id) | ID of the COS instance created by RT CSPM. Null when CDR infrastructure is used (CDR owns the COS bucket). |
| <a name="output_event_notifications_destination_id"></a> [event\_notifications\_destination\_id](#output\_event\_notifications\_destination\_id) | ID of the Event Notifications COS destination |
| <a name="output_event_notifications_subscription_id"></a> [event\_notifications\_subscription\_id](#output\_event\_notifications\_subscription\_id) | ID of the Event Notifications COS subscription |
| <a name="output_event_notifications_topic_id"></a> [event\_notifications\_topic\_id](#output\_event\_notifications\_topic\_id) | ID of the Event Notifications topic that filters App Configuration aggregator events |
| <a name="output_rt_cspm_ingestion_endpoint"></a> [rt\_cspm\_ingestion\_endpoint](#output\_rt\_cspm\_ingestion\_endpoint) | Sysdig ingestion URL for RT CSPM events. Null when CDR infrastructure is used. |
| <a name="output_service_api_key"></a> [service\_api\_key](#output\_service\_api\_key) | API key of the service ID used by RT CSPM. Null when CDR infrastructure is used. |
| <a name="output_service_id"></a> [service\_id](#output\_service\_id) | ID of the service ID used by RT CSPM. Null when CDR infrastructure is used. |
| <a name="output_trusted_profile_id"></a> [trusted\_profile\_id](#output\_trusted\_profile\_id) | ID of the trusted profile used by RT CSPM. Null when CDR infrastructure is used. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
