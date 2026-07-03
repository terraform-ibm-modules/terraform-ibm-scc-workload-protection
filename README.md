<!-- Update the title -->
# Security and Compliance Center Workload Protection module

[![Graduated (Supported)](https://img.shields.io/badge/Status-Graduated%20(Supported)-brightgreen)](https://terraform-ibm-modules.github.io/documentation/#/badge-status)
[![latest release](https://img.shields.io/github/v/release/terraform-ibm-modules/terraform-ibm-scc-workload-protection?logo=GitHub&sort=semver)](https://github.com/terraform-ibm-modules/terraform-ibm-scc-workload-protection/releases/latest)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![Renovate enabled](https://img.shields.io/badge/renovate-enabled-brightgreen.svg)](https://renovatebot.com/)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)
[![Terraform Registry](https://img.shields.io/badge/terraform-registry-623CE4?logo=terraform)](https://registry.terraform.io/modules/terraform-ibm-modules/scc-workload-protection/ibm/latest)

<!-- Add a description of module(s) in this repo -->
A module for configuring an [IBM Cloud Security and Compliance Center Workload Protection](https://cloud.ibm.com/docs/workload-protection?topic=workload-protection-getting-started) instance. The module will always create a Manager resource key that connects to the SCC WP instance. Some sub-resources can be created using the [Sysdig Provider](https://registry.terraform.io/providers/sysdiglabs/sysdig/latest/docs) (see [advanced](./examples/advanced) example).

<!-- Below content is automatically populated via pre-commit hook -->
<!-- BEGIN OVERVIEW HOOK -->
## Overview
<ul>
  <li><a href="#terraform-ibm-scc-workload-protection">terraform-ibm-scc-workload-protection</a></li>
  <li><a href="https://github.com/terraform-ibm-modules/terraform-ibm-scc-workload-protection/tree/main/modules">Submodules</a>
    <ul>
      <li><a href="https://github.com/terraform-ibm-modules/terraform-ibm-scc-workload-protection/tree/main/modules/account_check">account_check</a></li>
      <li><a href="https://github.com/terraform-ibm-modules/terraform-ibm-scc-workload-protection/tree/main/modules/cdr">cdr</a></li>
    </ul>
  </li>
  <li><a href="https://github.com/terraform-ibm-modules/terraform-ibm-scc-workload-protection/tree/main/examples">Examples</a>
    <ul>
      <li>
        <a href="https://github.com/terraform-ibm-modules/terraform-ibm-scc-workload-protection/tree/main/examples/advanced">Advanced example</a>
        <a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=scc-workload-protection-advanced-example&repository=https://github.com/terraform-ibm-modules/terraform-ibm-scc-workload-protection/tree/main/examples/advanced"><img src="https://img.shields.io/badge/Deploy%20with%20IBM%20Cloud%20Schematics-0f62fe?style=flat&logo=ibm&logoColor=white&labelColor=0f62fe" alt="Deploy with IBM Cloud Schematics" style="height: 16px; vertical-align: text-bottom; margin-left: 5px;"></a>
      </li>
      <li>
        <a href="https://github.com/terraform-ibm-modules/terraform-ibm-scc-workload-protection/tree/main/examples/basic">Basic example</a>
        <a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=scc-workload-protection-basic-example&repository=https://github.com/terraform-ibm-modules/terraform-ibm-scc-workload-protection/tree/main/examples/basic"><img src="https://img.shields.io/badge/Deploy%20with%20IBM%20Cloud%20Schematics-0f62fe?style=flat&logo=ibm&logoColor=white&labelColor=0f62fe" alt="Deploy with IBM Cloud Schematics" style="height: 16px; vertical-align: text-bottom; margin-left: 5px;"></a>
      </li>
      <li>
        <a href="https://github.com/terraform-ibm-modules/terraform-ibm-scc-workload-protection/tree/main/examples/cdr">CDR example</a>
        <a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=scc-workload-protection-cdr-example&repository=https://github.com/terraform-ibm-modules/terraform-ibm-scc-workload-protection/tree/main/examples/cdr"><img src="https://img.shields.io/badge/Deploy%20with%20IBM%20Cloud%20Schematics-0f62fe?style=flat&logo=ibm&logoColor=white&labelColor=0f62fe" alt="Deploy with IBM Cloud Schematics" style="height: 16px; vertical-align: text-bottom; margin-left: 5px;"></a>
      </li>
      <li>
        <a href="https://github.com/terraform-ibm-modules/terraform-ibm-scc-workload-protection/tree/main/examples/enterprise">Enterprise example with CSPM enabled</a>
        <a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=scc-workload-protection-enterprise-example&repository=https://github.com/terraform-ibm-modules/terraform-ibm-scc-workload-protection/tree/main/examples/enterprise"><img src="https://img.shields.io/badge/Deploy%20with%20IBM%20Cloud%20Schematics-0f62fe?style=flat&logo=ibm&logoColor=white&labelColor=0f62fe" alt="Deploy with IBM Cloud Schematics" style="height: 16px; vertical-align: text-bottom; margin-left: 5px;"></a>
      </li>
    </ul>
    ℹ️ Ctrl/Cmd+Click or right-click on the Schematics deploy button to open in a new tab.
  </li>
  <li><a href="https://github.com/terraform-ibm-modules/terraform-ibm-scc-workload-protection/tree/main/solutions">Deployable Architectures</a>
    <ul>
      <li><a href="https://github.com/terraform-ibm-modules/terraform-ibm-scc-workload-protection/tree/main/solutions/fully-configurable">Cloud automation for Security and Compliance Center Workload Protection (Fully configurable)</a></li>
    </ul>
  </li>
  <li><a href="#contributing">Contributing</a></li>
</ul>
<!-- END OVERVIEW HOOK -->

<!-- This heading should always match the name of the root level module (aka the repo name) -->
## terraform-ibm-scc-workload-protection

### Usage

<!--
Add an example of the use of the module in the following code block.

Use real values instead of "var.<var_name>" or other placeholder values
unless real values don't help users know what to change.
-->

```hcl
data "ibm_iam_auth_token" "auth_token" {}

provider "restapi" {
  # see https://cloud.ibm.com/apidocs/resource-controller/resource-controller#endpoint-url for full list of available resource controller endpoints
  uri = "https:"
  headers = {
    Authorization  = data.ibm_iam_auth_token.auth_token.iam_access_token
  }
  write_returns_object = true
}

module "scc_wp" {
  source                        = "terraform-ibm-modules/scc-workload-protection/ibm"
  version                       = "X.X.X" # Replace "X.X.X" with a release version to lock into a specific release
  name                          = "my-scc-wp-service"
  region                        = "us-south"
  resource_group_id             = "65xxxxxxxxxxxxxxxa3fd"
  resource_key_tags             = ["scc-wp-tag"]
  cloud_monitoring_instance_crn = "crn:v1:bluemix:public:sysdig-monitor:us-south:a/xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX:xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX::"
  app_config_crn                = "crn:v1:bluemix:public:apprap:us-south:a/xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX:xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX::"
}
```

### Known limitations

#### CSPM configuration drift detection

When CSPM is enabled (`cspm_enabled = true`), the module uses the `restapi` provider to configure the CSPM parameters. Due to a [workaround](https://github.com/Mastercard/terraform-provider-restapi/issues/319) for the restapi provider, Terraform will **not detect drift** if the following parameters are changed outside of Terraform (e.g., via the console, CLI, or API):

- `enable_cspm`
- `target_accounts` (including `account_id`, `account_type`, `config_crn`, `trusted_profile_id`)

This means the CSPM configuration should be fully managed by Terraform. Any out-of-band changes will not be detected or reverted.

This limitation will be resolved when the module is updated to use restapi provider v3.0.0 with `ignore_server_additions`.

### Required IAM access policies

<!-- PERMISSIONS REQUIRED TO RUN MODULE
If this module requires permissions, uncomment the following block and update
the sample permissions, following the format.
Replace the sample Account and IBM Cloud service names and roles with the
information in the console at
Manage > Access (IAM) > Access groups > Access policies.
-->

You need the following permissions to run this module.

- IAM Services
    - **IBM Cloud Security and Compliance Center Workload Protection** service
        - `Editor` platform access
        - `Writer` service access

<!-- NO PERMISSIONS FOR MODULE
If no permissions are required for the module, uncomment the following
statement instead the previous block.
-->

<!-- No permissions are needed to run this module.-->


<!-- Below content is automatically populated via pre-commit hook -->
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
| <a name="module_account_type_check"></a> [account\_type\_check](#module\_account\_type\_check) | ./modules/account_check | n/a |
| <a name="module_cbr_rule"></a> [cbr\_rule](#module\_cbr\_rule) | terraform-ibm-modules/cbr/ibm//modules/cbr-rule-module | 1.36.6 |
| <a name="module_cdr"></a> [cdr](#module\_cdr) | ./modules/cdr | n/a |
| <a name="module_trusted_profile_scc_wp"></a> [trusted\_profile\_scc\_wp](#module\_trusted\_profile\_scc\_wp) | terraform-ibm-modules/trusted-profile/ibm | 4.2.0 |

### Resources

| Name | Type |
|------|------|
| [ibm_resource_instance.scc_wp](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/resource_instance) | resource |
| [ibm_resource_key.scc_wp_resource_key](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/resource_key) | resource |
| [ibm_resource_tag.scc_wp_access_tag](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/resource_tag) | resource |
| [restapi_object.cspm](https://registry.terraform.io/providers/Mastercard/restapi/latest/docs/resources/object) | resource |
| [ibm_iam_access_tag.access_tags](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/data-sources/iam_access_tag) | data source |
| [ibm_iam_auth_token.token](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/data-sources/iam_auth_token) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_tags"></a> [access\_tags](#input\_access\_tags) | Add access management tags to the SCC WP instance to control access. [Learn more](https://cloud.ibm.com/docs/account?topic=account-tag&interface=ui#create-access-console). | `list(string)` | `[]` | no |
| <a name="input_app_config_crn"></a> [app\_config\_crn](#input\_app\_config\_crn) | The CRN of an existing App Config instance to use with the SCC Workload Protection instance. Required if `cspm_enabled` is true. NOTE: Ensure the App Config instance has configuration aggregator enabled. | `string` | `null` | no |
| <a name="input_cbr_rules"></a> [cbr\_rules](#input\_cbr\_rules) | The context-based restrictions rule to create. Only one rule is allowed. | <pre>list(object({<br/>    description = string<br/>    account_id  = string<br/>    tags = optional(list(object({<br/>      name  = string<br/>      value = string<br/>    })), [])<br/>    rule_contexts = list(object({<br/>      attributes = optional(list(object({<br/>        name  = string<br/>        value = string<br/>    }))) }))<br/>    enforcement_mode = string<br/>  }))</pre> | `[]` | no |
| <a name="input_cdr_atracker_locations"></a> [cdr\_atracker\_locations](#input\_cdr\_atracker\_locations) | List of locations to route Activity Tracker events from. Use ['*'] for all locations. Ensure that the route rule includes the `global` location in addition to your deployment region. | `list(string)` | <pre>[<br/>  "global"<br/>]</pre> | no |
| <a name="input_cdr_atracker_route_name"></a> [cdr\_atracker\_route\_name](#input\_cdr\_atracker\_route\_name) | Name of the Activity Tracker route. | `string` | `null` | no |
| <a name="input_cdr_atracker_target_name"></a> [cdr\_atracker\_target\_name](#input\_cdr\_atracker\_target\_name) | Name of the Activity Tracker target. | `string` | `null` | no |
| <a name="input_cdr_ce_api_secret_name"></a> [cdr\_ce\_api\_secret\_name](#input\_cdr\_ce\_api\_secret\_name) | The name of the secret for the Code Engine application. | `string` | `"cdr-api-secret"` | no |
| <a name="input_cdr_ce_app_cpu"></a> [cdr\_ce\_app\_cpu](#input\_cdr\_ce\_app\_cpu) | CPU limit for Code Engine app | `string` | `"0.125"` | no |
| <a name="input_cdr_ce_app_image"></a> [cdr\_ce\_app\_image](#input\_cdr\_ce\_app\_image) | The CDR notification application image hosted in IBM Cloud Container Registry. | `string` | `"icr.io/ext/sysdig/cdr-notification-app:latest"` | no |
| <a name="input_cdr_ce_app_max_scale"></a> [cdr\_ce\_app\_max\_scale](#input\_cdr\_ce\_app\_max\_scale) | Maximum number of instances for Code Engine app | `number` | `10` | no |
| <a name="input_cdr_ce_app_memory"></a> [cdr\_ce\_app\_memory](#input\_cdr\_ce\_app\_memory) | Memory limit for Code Engine app | `string` | `"500M"` | no |
| <a name="input_cdr_ce_app_min_scale"></a> [cdr\_ce\_app\_min\_scale](#input\_cdr\_ce\_app\_min\_scale) | Minimum number of instances for Code Engine app. Set to 1 to ensure the app is always ready to receive Object Storage events. | `number` | `1` | no |
| <a name="input_cdr_ce_app_name"></a> [cdr\_ce\_app\_name](#input\_cdr\_ce\_app\_name) | The name of the Code Engine application for CDR. | `string` | `"ce-cdr-app"` | no |
| <a name="input_cdr_ce_app_timeout"></a> [cdr\_ce\_app\_timeout](#input\_cdr\_ce\_app\_timeout) | Request timeout in seconds for Code Engine app | `number` | `60` | no |
| <a name="input_cdr_ce_icr_secret_name"></a> [cdr\_ce\_icr\_secret\_name](#input\_cdr\_ce\_icr\_secret\_name) | The name of the secret for pulling images from Container Registry. | `string` | `"cdr-icr-secret"` | no |
| <a name="input_cdr_ce_project_name"></a> [cdr\_ce\_project\_name](#input\_cdr\_ce\_project\_name) | The name of the Code Engine project for CDR. | `string` | `"cdr-ce-project"` | no |
| <a name="input_cdr_ce_run_service_account"></a> [cdr\_ce\_run\_service\_account](#input\_cdr\_ce\_run\_service\_account) | The name of the service account. | `string` | `"default"` | no |
| <a name="input_cdr_cos_bucket_name"></a> [cdr\_cos\_bucket\_name](#input\_cdr\_cos\_bucket\_name) | Name of the COS bucket to be used as target for Activity Tracker Event Routing events | `string` | `"cdr-events-bucket"` | no |
| <a name="input_cdr_cos_bucket_storage_class"></a> [cdr\_cos\_bucket\_storage\_class](#input\_cdr\_cos\_bucket\_storage\_class) | Storage class for the COS bucket. | `string` | `"smart"` | no |
| <a name="input_cdr_cos_instance_name"></a> [cdr\_cos\_instance\_name](#input\_cdr\_cos\_instance\_name) | Name of the COS instance to be used as target for Activity Tracker Event Routing events. | `string` | `null` | no |
| <a name="input_cdr_cos_plan"></a> [cdr\_cos\_plan](#input\_cdr\_cos\_plan) | Plan for the COS instance. | `string` | `"standard"` | no |
| <a name="input_cdr_enabled"></a> [cdr\_enabled](#input\_cdr\_enabled) | Enable Cloud Detection and Response (CDR) for the Workload Protection instance. This will create infrastructure to forward Activity Tracker events to SCC-WP for compliance scanning. Requires CSPM to be enabled. [Learn more](https://cloud.ibm.com/docs/workload-protection?topic=workload-protection-about). | `bool` | `false` | no |
| <a name="input_cdr_iam_service_id_name"></a> [cdr\_iam\_service\_id\_name](#input\_cdr\_iam\_service\_id\_name) | Name of the Service ID for the Code Engine application to send events to Workload Protection instance. | `string` | `"cdr-ce-service-id"` | no |
| <a name="input_cdr_iam_service_policy_name"></a> [cdr\_iam\_service\_policy\_name](#input\_cdr\_iam\_service\_policy\_name) | Name of the IAM Service policy having reader access for Container Registry. | `string` | `"container-registry-reader"` | no |
| <a name="input_cdr_install_required_binaries"></a> [cdr\_install\_required\_binaries](#input\_cdr\_install\_required\_binaries) | When set to true, a script will run to check if `jq`, the `ibmcloud` CLI, and the `code-engine` plugin exist on the runtime and if not attempt to download them from the public internet and install them to /tmp. Set to false to skip running this script. | `bool` | `true` | no |
| <a name="input_cdr_kms_encryption_enabled"></a> [cdr\_kms\_encryption\_enabled](#input\_cdr\_kms\_encryption\_enabled) | Enable KMS encryption for the COS bucket | `bool` | `false` | no |
| <a name="input_cdr_kms_key_crn"></a> [cdr\_kms\_key\_crn](#input\_cdr\_kms\_key\_crn) | CRN of the KMS key to use for bucket encryption. Required if kms\_encryption\_enabled is true | `string` | `null` | no |
| <a name="input_cdr_skip_iam_authorization_policy"></a> [cdr\_skip\_iam\_authorization\_policy](#input\_cdr\_skip\_iam\_authorization\_policy) | Set to true to skip the creation of an IAM authorization policy that permits the COS instance to read the encryption key from the KMS instance | `bool` | `true` | no |
| <a name="input_cdr_subscription_name"></a> [cdr\_subscription\_name](#input\_cdr\_subscription\_name) | The name of the COS event subscription to code engine. | `string` | `"cdr-cos-ce-subscriptions"` | no |
| <a name="input_cdr_trusted_profile_name"></a> [cdr\_trusted\_profile\_name](#input\_cdr\_trusted\_profile\_name) | The trusted profile for Workload Protection interaction with cloud object storage bucket. | `string` | `"cdr-wp-trusted-profile"` | no |
| <a name="input_cloud_monitoring_instance_crn"></a> [cloud\_monitoring\_instance\_crn](#input\_cloud\_monitoring\_instance\_crn) | To collect and analyze metrics and security data on hosts using both Monitoring and Workload Protection, pass the CRN of an existing IBM Cloud Monitoring instance to create the connection. Once the connection is created, the Monitoring instance CRN cannot be changed. | `string` | `null` | no |
| <a name="input_cspm_enabled"></a> [cspm\_enabled](#input\_cspm\_enabled) | Enable Cloud Security Posture Management (CSPM) for the Workload Protection instance. This will create a trusted profile associated with the SCC Workload Protection instance that has viewer / reader access to the App Config service and viewer access to the Enterprise service. [Learn more](https://cloud.ibm.com/docs/workload-protection?topic=workload-protection-about). | `bool` | `true` | no |
| <a name="input_existing_cos_instance_id"></a> [existing\_cos\_instance\_id](#input\_existing\_cos\_instance\_id) | Existing COS instance to pass in. If set to `null`, a new instance will be created. | `string` | `null` | no |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud\_api\_key](#input\_ibmcloud\_api\_key) | IBM Cloud API key for authenticating with IBM Cloud services. Required for CDR functionality. | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | The name to give the SCC Workload Protection instance that will be provisioned by this module. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | IBM Cloud region where all resources will be deployed | `string` | `"us-south"` | no |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | The resource group ID where resources will be provisioned. | `string` | n/a | yes |
| <a name="input_resource_key_name"></a> [resource\_key\_name](#input\_resource\_key\_name) | The name to give the IBM Cloud SCC WP resource key. | `string` | `"SCCWPManagerKey"` | no |
| <a name="input_resource_key_tags"></a> [resource\_key\_tags](#input\_resource\_key\_tags) | Tags associated with the IBM Cloud SCC WP resource key. | `list(string)` | `[]` | no |
| <a name="input_resource_tags"></a> [resource\_tags](#input\_resource\_tags) | Add user resource tags to the SCC WP instance to organize, track, and manage costs. [Learn more](https://cloud.ibm.com/docs/account?topic=account-tag&interface=ui#tag-types). | `list(string)` | `[]` | no |
| <a name="input_scc_workload_protection_trusted_profile_name"></a> [scc\_workload\_protection\_trusted\_profile\_name](#input\_scc\_workload\_protection\_trusted\_profile\_name) | The name to give the trusted profile that is created by this module if `cspm_enabled` is `true. Must begin with a letter.` | `string` | `"workload-protection-trusted-profile"` | no |
| <a name="input_scc_wp_service_plan"></a> [scc\_wp\_service\_plan](#input\_scc\_wp\_service\_plan) | IBM service pricing plan. | `string` | `"free-trial"` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_key"></a> [access\_key](#output\_access\_key) | Workload Protection instance access key. |
| <a name="output_account_id"></a> [account\_id](#output\_account\_id) | Account ID of created SCC WP instance. |
| <a name="output_api_endpoint"></a> [api\_endpoint](#output\_api\_endpoint) | API endpoint. |
| <a name="output_cdr_atracker_route_id"></a> [cdr\_atracker\_route\_id](#output\_cdr\_atracker\_route\_id) | ID of the Activity Tracker route |
| <a name="output_cdr_atracker_target_crn"></a> [cdr\_atracker\_target\_crn](#output\_cdr\_atracker\_target\_crn) | CRN of the Activity Tracker target |
| <a name="output_cdr_atracker_target_id"></a> [cdr\_atracker\_target\_id](#output\_cdr\_atracker\_target\_id) | ID of the Activity Tracker target |
| <a name="output_cdr_code_engine_app"></a> [cdr\_code\_engine\_app](#output\_cdr\_code\_engine\_app) | Code Engine app details for CDR |
| <a name="output_cdr_code_engine_app_url"></a> [cdr\_code\_engine\_app\_url](#output\_cdr\_code\_engine\_app\_url) | URL of the Code Engine app |
| <a name="output_cdr_code_engine_project_id"></a> [cdr\_code\_engine\_project\_id](#output\_cdr\_code\_engine\_project\_id) | ID of the Code Engine project |
| <a name="output_cdr_code_engine_secrets"></a> [cdr\_code\_engine\_secrets](#output\_cdr\_code\_engine\_secrets) | Code Engine secrets created for CDR |
| <a name="output_cdr_cos_bucket_crn"></a> [cdr\_cos\_bucket\_crn](#output\_cdr\_cos\_bucket\_crn) | CRN of the COS bucket |
| <a name="output_cdr_cos_bucket_id"></a> [cdr\_cos\_bucket\_id](#output\_cdr\_cos\_bucket\_id) | ID of the COS bucket |
| <a name="output_cdr_cos_bucket_name"></a> [cdr\_cos\_bucket\_name](#output\_cdr\_cos\_bucket\_name) | Name of the COS bucket for Activity Tracker events |
| <a name="output_cdr_cos_instance_crn"></a> [cdr\_cos\_instance\_crn](#output\_cdr\_cos\_instance\_crn) | CRN of the COS instance created for CDR |
| <a name="output_cdr_cos_instance_guid"></a> [cdr\_cos\_instance\_guid](#output\_cdr\_cos\_instance\_guid) | GUID of the COS instance created for CDR |
| <a name="output_cdr_cos_instance_id"></a> [cdr\_cos\_instance\_id](#output\_cdr\_cos\_instance\_id) | ID of the COS instance created for CDR |
| <a name="output_cdr_ingestion_endpoint"></a> [cdr\_ingestion\_endpoint](#output\_cdr\_ingestion\_endpoint) | Sysdig ingestion URL for CDR events |
| <a name="output_cdr_service_api_key"></a> [cdr\_service\_api\_key](#output\_cdr\_service\_api\_key) | API key for CDR service authentication |
| <a name="output_cdr_service_id"></a> [cdr\_service\_id](#output\_cdr\_service\_id) | IAM ID of the service ID created for CDR |
| <a name="output_cdr_service_id_crn"></a> [cdr\_service\_id\_crn](#output\_cdr\_service\_id\_crn) | CRN of the service ID created for CDR |
| <a name="output_cdr_service_policy_ids"></a> [cdr\_service\_policy\_ids](#output\_cdr\_service\_policy\_ids) | List of service policy IDs |
| <a name="output_cdr_trusted_profile_id"></a> [cdr\_trusted\_profile\_id](#output\_cdr\_trusted\_profile\_id) | ID of the CDR trusted profile |
| <a name="output_cdr_trusted_profile_name"></a> [cdr\_trusted\_profile\_name](#output\_cdr\_trusted\_profile\_name) | Name of the CDR trusted profile |
| <a name="output_cdr_trusted_profile_policies"></a> [cdr\_trusted\_profile\_policies](#output\_cdr\_trusted\_profile\_policies) | List of policies attached to the CDR trusted profile |
| <a name="output_crn"></a> [crn](#output\_crn) | CRN of created SCC WP instance. |
| <a name="output_guid"></a> [guid](#output\_guid) | GUID of created SCC WP instance. |
| <a name="output_id"></a> [id](#output\_id) | ID of created SCC WP instance. |
| <a name="output_ingestion_endpoint"></a> [ingestion\_endpoint](#output\_ingestion\_endpoint) | Ingestion endpoint. |
| <a name="output_name"></a> [name](#output\_name) | Name of created SCC WP instance. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- Leave this section as is so that your module has a link to local development environment set up steps for contributors to follow -->
## Contributing

You can report issues and request features for this module in GitHub issues in the module repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.
