# CDR (Cloud Detection and Response)

This submodule creates the infrastructure required for forwarding Activity Tracker events to IBM Cloud Security and Compliance Center Workload Protection for Cloud Detection and Response (CDR) compliance scanning.

## Architecture

The module sets up an end-to-end pipeline:

1. **Activity Tracker → COS**: Routes activity logs to Cloud Object Storage bucket
2. **COS → Code Engine**: Triggers Code Engine app on bucket write events
3. **Code Engine App**: Forwards events to SCC Workload Protection ingestion endpoint
4. **SCC-WP**: Analyzes events and triggers alerts for potential security risks

## Prerequisites

- IBM Cloud CLI installed and authenticated
- IBM Cloud Code Engine CLI plugin installed (`ibmcloud ce version`)
- Existing SCC Workload Protection instance with trusted profile and CSPM enabled

### Usage

```hcl
module "cdr" {
  source  = "terraform-ibm-modules/scc-workload-protection/ibm//modules/cdr"
  version = "X.X.X" # Replace with a release version

  # IBM Cloud Authentication
  ibmcloud_api_key = "xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX" #pragma: allowlist secret

  # Basic Configuration
  region            = "us-south"
  resource_group_id = "xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX"

  # IAM Service ID
  iam_service_id_name = "cdr-service-id"

  # Cloud Object Storage
  cos_instance_name = "cdr-cos-instance"
  cos_bucket_name   = "cdr-events-bucket"

  # Trusted Profile
  trusted_profile_name = "cdr-trusted-profile"

  # SCC Workload Protection
  target_account_id        = "xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX"
  sysdig_environment_url   = "us-south.security-compliance-secure.cloud.ibm.com"
  workload_protection_crn  = "crn:v1:bluemix:public:sysdig-secure:us-south:a/xxxx:xxxx::"
  workload_protection_guid = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

  # Code Engine
  ce_project_name = "cdr-code-engine-project"
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
  - **Cloud Object Storage** service
      - `Manager` service access - Required to create and manage COS instances and buckets
  - **Code Engine** service
      - `Editor` or `Manager` service access - Required to create Code Engine projects, apps, and subscriptions
  - **Container Registry** service
      - `Reader` service access - Required for Code Engine to pull the CDR application image
  - **IBM Cloud Security and Compliance Center Workload Protection** service
      - `Editor` or `Administrator` platform access - Required to configure and manage Workload Protection instances

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.89.0, <3.0.0 |
| <a name="requirement_restapi"></a> [restapi](#requirement\_restapi) | >=2.0.1, <3.0.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_activity_tracker"></a> [activity\_tracker](#module\_activity\_tracker) | terraform-ibm-modules/activity-tracker/ibm | 1.8.8 |
| <a name="module_cdr_service_id"></a> [cdr\_service\_id](#module\_cdr\_service\_id) | terraform-ibm-modules/iam-service-id/ibm | 1.3.0 |
| <a name="module_cdr_trusted_profile"></a> [cdr\_trusted\_profile](#module\_cdr\_trusted\_profile) | terraform-ibm-modules/trusted-profile/ibm | 4.1.0 |
| <a name="module_code_engine_app"></a> [code\_engine\_app](#module\_code\_engine\_app) | terraform-ibm-modules/code-engine/ibm//modules/app | 4.9.6 |
| <a name="module_code_engine_project"></a> [code\_engine\_project](#module\_code\_engine\_project) | terraform-ibm-modules/code-engine/ibm | 4.9.6 |
| <a name="module_cos"></a> [cos](#module\_cos) | terraform-ibm-modules/cos/ibm | 10.16.5 |

### Resources

| Name | Type |
|------|------|
| [ibm_iam_authorization_policy.ce_to_cos](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/iam_authorization_policy) | resource |
| [ibm_iam_trusted_profile_identity.service_id](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/iam_trusted_profile_identity) | resource |
| [restapi_object.cdr](https://registry.terraform.io/providers/Mastercard/restapi/latest/docs/resources/object) | resource |
| [terraform_data.cdr_cos_subscription](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [terraform_data.install_required_binaries](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_atracker_locations"></a> [atracker\_locations](#input\_atracker\_locations) | List of locations to route Activity Tracker events from. Use ['*'] for all locations. Ensure that the route rule includes the `global` location in addition to your deployment region. | `list(string)` | <pre>[<br/>  "global"<br/>]</pre> | no |
| <a name="input_atracker_route_name"></a> [atracker\_route\_name](#input\_atracker\_route\_name) | Name of the Activity Tracker route. | `string` | `null` | no |
| <a name="input_atracker_target_name"></a> [atracker\_target\_name](#input\_atracker\_target\_name) | Name of the Activity Tracker target. | `string` | `null` | no |
| <a name="input_cdr_ce_app_image"></a> [cdr\_ce\_app\_image](#input\_cdr\_ce\_app\_image) | The CDR notification application image hosted in IBM Cloud Container Registry. | `string` | `"icr.io/ext/sysdig/cdr-notification-app:latest"` | no |
| <a name="input_ce_api_secret_name"></a> [ce\_api\_secret\_name](#input\_ce\_api\_secret\_name) | The name of the secret for the Code Engine application. | `string` | `"cdr-api-secret"` | no |
| <a name="input_ce_app_cpu"></a> [ce\_app\_cpu](#input\_ce\_app\_cpu) | CPU limit for Code Engine app | `string` | `"0.125"` | no |
| <a name="input_ce_app_max_scale"></a> [ce\_app\_max\_scale](#input\_ce\_app\_max\_scale) | Maximum number of instances for Code Engine app | `number` | `10` | no |
| <a name="input_ce_app_memory"></a> [ce\_app\_memory](#input\_ce\_app\_memory) | Memory limit for Code Engine app | `string` | `"500M"` | no |
| <a name="input_ce_app_min_scale"></a> [ce\_app\_min\_scale](#input\_ce\_app\_min\_scale) | Minimum number of instances for Code Engine app. Set to 1 to ensure the app is always ready to receive Object Storage events. | `number` | `1` | no |
| <a name="input_ce_app_name"></a> [ce\_app\_name](#input\_ce\_app\_name) | The name of the Code Engine application for CDR. | `string` | `"ce-cdr-app"` | no |
| <a name="input_ce_app_timeout"></a> [ce\_app\_timeout](#input\_ce\_app\_timeout) | Request timeout in seconds for Code Engine app | `number` | `60` | no |
| <a name="input_ce_icr_secret_name"></a> [ce\_icr\_secret\_name](#input\_ce\_icr\_secret\_name) | The name of the secret for pulling images from Container Registry. | `string` | `"cdr-icr-secret"` | no |
| <a name="input_ce_project_name"></a> [ce\_project\_name](#input\_ce\_project\_name) | The name of the Code Engine project for CDR. | `string` | n/a | yes |
| <a name="input_ce_run_service_account"></a> [ce\_run\_service\_account](#input\_ce\_run\_service\_account) | The name of the service account. | `string` | `"default"` | no |
| <a name="input_cos_bucket_name"></a> [cos\_bucket\_name](#input\_cos\_bucket\_name) | Name of the COS bucket to be used as target for Activity Tracker Event Routing events | `string` | n/a | yes |
| <a name="input_cos_bucket_storage_class"></a> [cos\_bucket\_storage\_class](#input\_cos\_bucket\_storage\_class) | Storage class for the COS bucket. | `string` | `"smart"` | no |
| <a name="input_cos_instance_name"></a> [cos\_instance\_name](#input\_cos\_instance\_name) | Name of the COS instance to be used as target for Activity Tracker Event Routing events. | `string` | `null` | no |
| <a name="input_cos_plan"></a> [cos\_plan](#input\_cos\_plan) | Plan for the COS instance. | `string` | `"standard"` | no |
| <a name="input_existing_cos_instance_id"></a> [existing\_cos\_instance\_id](#input\_existing\_cos\_instance\_id) | Existing COS instance to pass in. If set to `null`, a new instance will be created. | `string` | `null` | no |
| <a name="input_iam_service_id_name"></a> [iam\_service\_id\_name](#input\_iam\_service\_id\_name) | Name of the Service ID for the Code Engine application to send events to Workload Protection instance. | `string` | n/a | yes |
| <a name="input_iam_service_policy_name"></a> [iam\_service\_policy\_name](#input\_iam\_service\_policy\_name) | Name of the IAM Service policy having reader access for Container Registry. | `string` | `"container-registry-reader"` | no |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud\_api\_key](#input\_ibmcloud\_api\_key) | IBM Cloud API key for authenticating with IBM Cloud services | `string` | n/a | yes |
| <a name="input_install_required_binaries"></a> [install\_required\_binaries](#input\_install\_required\_binaries) | When set to true, a script will run to check if `jq`, the `ibmcloud` CLI, and the `code-engine` plugin exist on the runtime and if not attempt to download them from the public internet and install them to /tmp. Set to false to skip running this script. | `bool` | `true` | no |
| <a name="input_kms_encryption_enabled"></a> [kms\_encryption\_enabled](#input\_kms\_encryption\_enabled) | Enable KMS encryption for the COS bucket | `bool` | `false` | no |
| <a name="input_kms_key_crn"></a> [kms\_key\_crn](#input\_kms\_key\_crn) | CRN of the KMS key to use for bucket encryption. Required if kms\_encryption\_enabled is true | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | IBM Cloud region where CDR resources will be deployed | `string` | n/a | yes |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | The resource group ID in which CDR resources will be provisioned | `string` | n/a | yes |
| <a name="input_resource_tags"></a> [resource\_tags](#input\_resource\_tags) | Optional list of tags to be added to CDR resources | `list(string)` | `[]` | no |
| <a name="input_skip_iam_authorization_policy"></a> [skip\_iam\_authorization\_policy](#input\_skip\_iam\_authorization\_policy) | Set to true to skip the creation of an IAM authorization policy that permits the COS instance to read the encryption key from the KMS instance | `bool` | `true` | no |
| <a name="input_subscription_name"></a> [subscription\_name](#input\_subscription\_name) | The name of the COS event subscription to code engine. | `string` | `"cdr-cos-ce-subscription"` | no |
| <a name="input_sysdig_environment_url"></a> [sysdig\_environment\_url](#input\_sysdig\_environment\_url) | The sysdig workload protection environment URL (e.g. 'us-south.security-compliance-secure.cloud.ibm.com'). | `string` | n/a | yes |
| <a name="input_target_account_id"></a> [target\_account\_id](#input\_target\_account\_id) | The IBM Cloud account ID whose auditing events are being forwarded via Activity Tracker Event Routing. | `string` | n/a | yes |
| <a name="input_trusted_profile_name"></a> [trusted\_profile\_name](#input\_trusted\_profile\_name) | The trusted profile for Workload Protection interaction with cloud object storage bucket. | `string` | n/a | yes |
| <a name="input_workload_protection_crn"></a> [workload\_protection\_crn](#input\_workload\_protection\_crn) | The CRN of the SCC Workload Protection instance for trusted profile identity. | `string` | n/a | yes |
| <a name="input_workload_protection_guid"></a> [workload\_protection\_guid](#input\_workload\_protection\_guid) | The GUID of the SCC Workload Protection instance for trusted profile identity. | `string` | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_atracker_route_id"></a> [atracker\_route\_id](#output\_atracker\_route\_id) | ID of the Activity Tracker route |
| <a name="output_atracker_target_crn"></a> [atracker\_target\_crn](#output\_atracker\_target\_crn) | CRN of the Activity Tracker target |
| <a name="output_atracker_target_id"></a> [atracker\_target\_id](#output\_atracker\_target\_id) | ID of the Activity Tracker target |
| <a name="output_cdr_ingestion_endpoint"></a> [cdr\_ingestion\_endpoint](#output\_cdr\_ingestion\_endpoint) | Sysdig ingestion URL for CDR events |
| <a name="output_code_engine_app"></a> [code\_engine\_app](#output\_code\_engine\_app) | Code Engine app details for CDR |
| <a name="output_code_engine_app_url"></a> [code\_engine\_app\_url](#output\_code\_engine\_app\_url) | URL of the Code Engine app |
| <a name="output_code_engine_project_id"></a> [code\_engine\_project\_id](#output\_code\_engine\_project\_id) | ID of the Code Engine project |
| <a name="output_code_engine_secrets"></a> [code\_engine\_secrets](#output\_code\_engine\_secrets) | Code Engine secrets created for CDR |
| <a name="output_cos_bucket_crn"></a> [cos\_bucket\_crn](#output\_cos\_bucket\_crn) | CRN of the COS bucket |
| <a name="output_cos_bucket_id"></a> [cos\_bucket\_id](#output\_cos\_bucket\_id) | ID of the COS bucket |
| <a name="output_cos_bucket_name"></a> [cos\_bucket\_name](#output\_cos\_bucket\_name) | Name of the COS bucket for Activity Tracker events |
| <a name="output_cos_instance_crn"></a> [cos\_instance\_crn](#output\_cos\_instance\_crn) | CRN of the COS instance created for CDR |
| <a name="output_cos_instance_guid"></a> [cos\_instance\_guid](#output\_cos\_instance\_guid) | GUID of the COS instance created for CDR |
| <a name="output_cos_instance_id"></a> [cos\_instance\_id](#output\_cos\_instance\_id) | ID of the COS instance created for CDR |
| <a name="output_service_api_key"></a> [service\_api\_key](#output\_service\_api\_key) | API key for CDR service authentication |
| <a name="output_service_id"></a> [service\_id](#output\_service\_id) | IAM ID of the service ID created for CDR |
| <a name="output_service_id_crn"></a> [service\_id\_crn](#output\_service\_id\_crn) | CRN of the service ID created for CDR |
| <a name="output_service_policy_ids"></a> [service\_policy\_ids](#output\_service\_policy\_ids) | List of service policy IDs |
| <a name="output_trusted_profile_id"></a> [trusted\_profile\_id](#output\_trusted\_profile\_id) | ID of the CDR trusted profile |
| <a name="output_trusted_profile_name"></a> [trusted\_profile\_name](#output\_trusted\_profile\_name) | Name of the CDR trusted profile |
| <a name="output_trusted_profile_policies"></a> [trusted\_profile\_policies](#output\_trusted\_profile\_policies) | List of policies attached to the CDR trusted profile |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
