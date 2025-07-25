<!-- Update the title -->
# Security and Compliance Center Workload Protection module

[![Stable (With quality checks)](https://img.shields.io/badge/Status-Stable%20(With%20quality%20checks)-green)](https://terraform-ibm-modules.github.io/documentation/#/badge-status)
[![latest release](https://img.shields.io/github/v/release/terraform-ibm-modules/terraform-ibm-scc-workload-protection?logo=GitHub&sort=semver)](https://github.com/terraform-ibm-modules/terraform-ibm-scc-workload-protection/releases/latest)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![Renovate enabled](https://img.shields.io/badge/renovate-enabled-brightgreen.svg)](https://renovatebot.com/)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)

<!-- Add a description of module(s) in this repo -->
A module for provisioning an [IBM Cloud Security and Compliance Center Workload Protection instance](https://cloud.ibm.com/docs/workload-protection?topic=workload-protection-getting-started). The module will always create a Manager resource key that connects to the SCC WP instance.

<!-- Below content is automatically populated via pre-commit hook -->
<!-- BEGIN OVERVIEW HOOK -->
## Overview
* [terraform-ibm-scc-workload-protection](#terraform-ibm-scc-workload-protection)
* [Examples](./examples)
    * [Advanced example](./examples/advanced)
    * [Basic example](./examples/basic)
    * [Enterprise example with CSPM enabled](./examples/enterprise)
* [Contributing](#contributing)
<!-- END OVERVIEW HOOK -->


<!--
If this repo contains any reference architectures, uncomment the heading below and links to them.
(Usually in the `/reference-architectures` directory.)
See "Reference architecture" in Authoring Guidelines in the public documentation at
https://terraform-ibm-modules.github.io/documentation/#/implementation-guidelines?id=reference-architecture
-->
<!-- ## Reference architectures -->


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
  uri = "https://resource-controller.cloud.ibm.com"
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

### Known issues
#### restapi_object.enable_cspm resource always identified for creation
There is currently a [known issue](https://github.com/terraform-ibm-modules/terraform-ibm-scc-workload-protection/issues/243) where you will always see the `restapi_object.enable_cspm` resource included in the terraform plan for creation, even after it has already been applied. It is safe to proceed with this apply and will be a no-op if the resource has already been applied.

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
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.79.2, <2.0.0 |
| <a name="requirement_restapi"></a> [restapi](#requirement\_restapi) | >=2.0.1, <3.0.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cbr_rule"></a> [cbr\_rule](#module\_cbr\_rule) | terraform-ibm-modules/cbr/ibm//modules/cbr-rule-module | 1.32.4 |
| <a name="module_trusted_profile_scc_wp"></a> [trusted\_profile\_scc\_wp](#module\_trusted\_profile\_scc\_wp) | terraform-ibm-modules/trusted-profile/ibm | 3.1.1 |

### Resources

| Name | Type |
|------|------|
| [ibm_resource_instance.scc_wp](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/resource_instance) | resource |
| [ibm_resource_key.scc_wp_resource_key](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/resource_key) | resource |
| [ibm_resource_tag.scc_wp_access_tag](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/resource_tag) | resource |
| [restapi_object.cspm](https://registry.terraform.io/providers/Mastercard/restapi/latest/docs/resources/object) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_tags"></a> [access\_tags](#input\_access\_tags) | A list of access tags to apply to the SCC WP instance created by the module. For more information, see https://cloud.ibm.com/docs/account?topic=account-access-tags-tutorial. | `list(string)` | `[]` | no |
| <a name="input_app_config_crn"></a> [app\_config\_crn](#input\_app\_config\_crn) | The CRN of an existing App Config instance to use with the SCC Workload Protection instance. Required if `cspm_enabled` is true. NOTE: Ensure the App Config instance has configuration aggregator enabled. | `string` | `null` | no |
| <a name="input_cbr_rules"></a> [cbr\_rules](#input\_cbr\_rules) | The list of context-based restriction rules to create. | <pre>list(object({<br/>    description = string<br/>    account_id  = string<br/>    tags = optional(list(object({<br/>      name  = string<br/>      value = string<br/>    })), [])<br/>    rule_contexts = list(object({<br/>      attributes = optional(list(object({<br/>        name  = string<br/>        value = string<br/>    }))) }))<br/>    enforcement_mode = string<br/>  }))</pre> | `[]` | no |
| <a name="input_cloud_monitoring_instance_crn"></a> [cloud\_monitoring\_instance\_crn](#input\_cloud\_monitoring\_instance\_crn) | To collect and analyze metrics and security data on hosts using both Monitoring and Workload Protection, pass the CRN of an existing IBM Cloud Monitoring instance to create a connection between instances. Both instances must be in the same region. | `string` | `null` | no |
| <a name="input_cspm_enabled"></a> [cspm\_enabled](#input\_cspm\_enabled) | Enable Cloud Security Posture Management (CSPM) for the Workload Protection instance. This will create a trusted profile associated with the SCC Workload Protection instance that has viewer / reader access to the App Config service and viewer access to the Enterprise service. [Learn more](https://cloud.ibm.com/docs/workload-protection?topic=workload-protection-about). | `bool` | `true` | no |
| <a name="input_name"></a> [name](#input\_name) | The name to give the SCC Workload Protection instance that will be provisioned by this module. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | IBM Cloud region where all resources will be deployed | `string` | `"us-south"` | no |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | The resource group ID where resources will be provisioned. | `string` | n/a | yes |
| <a name="input_resource_key_name"></a> [resource\_key\_name](#input\_resource\_key\_name) | The name to give the IBM Cloud SCC WP resource key. | `string` | `"SCCWPManagerKey"` | no |
| <a name="input_resource_key_tags"></a> [resource\_key\_tags](#input\_resource\_key\_tags) | Tags associated with the IBM Cloud SCC WP resource key. | `list(string)` | `[]` | no |
| <a name="input_resource_tags"></a> [resource\_tags](#input\_resource\_tags) | Optional list of tags to be added to created SCC WP instance. | `list(string)` | `[]` | no |
| <a name="input_scc_workload_protection_trusted_profile_name"></a> [scc\_workload\_protection\_trusted\_profile\_name](#input\_scc\_workload\_protection\_trusted\_profile\_name) | The name to give the trusted profile that is created by this module if `cspm_enabled` is `true. Must begin with a letter.` | `string` | `"workload-protection-trusted-profile"` | no |
| <a name="input_scc_wp_service_plan"></a> [scc\_wp\_service\_plan](#input\_scc\_wp\_service\_plan) | IBM service pricing plan. | `string` | `"free-trial"` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_key"></a> [access\_key](#output\_access\_key) | Workload Protection instance access key. |
| <a name="output_account_id"></a> [account\_id](#output\_account\_id) | Account ID of created SCC WP instance. |
| <a name="output_api_endpoint"></a> [api\_endpoint](#output\_api\_endpoint) | API endpoint. |
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
