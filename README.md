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
    * [Basic example](./examples/basic)
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
module "scc_wp" {
  source            = "terraform-ibm-modules/scc-workload-protection/ibm"
  version           = "X.X.X" # Replace "X.X.X" with a release version to lock into a specific release
  name              = "my-scc-wp-service"
  region            = "us-south"
  resource_group_id = "65xxxxxxxxxxxxxxxa3fd"
  resource_key_tags = ["scc-wp-tag"]
}
```

### Required IAM access policies

<!-- PERMISSIONS REQUIRED TO RUN MODULE
If this module requires permissions, uncomment the following block and update
the sample permissions, following the format.
Replace the sample Account and IBM Cloud service names and roles with the
information in the console at
Manage > Access (IAM) > Access groups > Access policies.
-->

<!--
You need the following permissions to run this module.

- Account Management
    - **Sample Account Service** service
        - `Editor` platform access
        - `Manager` service access
    - IAM Services
        - **Sample Cloud Service** service
            - `Administrator` platform access
-->

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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0, <1.6.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.58.1, <2.0.0 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [ibm_resource_instance.scc_wp](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/resource_instance) | resource |
| [ibm_resource_key.scc_wp_resource_key](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/resource_key) | resource |
| [ibm_resource_tag.scc_wp_access_tag](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/resource_tag) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_tags"></a> [access\_tags](#input\_access\_tags) | A list of access tags to apply to the SCC WP instance created by the module. For more information, see https://cloud.ibm.com/docs/account?topic=account-access-tags-tutorial. | `list(string)` | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | A identifier used as a prefix when naming resources that will be provisioned. Must begin with a letter. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | IBM Cloud region where all resources will be deployed | `string` | `"us-south"` | no |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | The resource group ID where resources will be provisioned. | `string` | n/a | yes |
| <a name="input_resource_key_name"></a> [resource\_key\_name](#input\_resource\_key\_name) | The name to give the IBM Cloud SCC WP resource key. | `string` | `"SCCWPManagerKey"` | no |
| <a name="input_resource_key_tags"></a> [resource\_key\_tags](#input\_resource\_key\_tags) | Tags associated with the IBM Cloud SCC WP resource key. | `list(string)` | `[]` | no |
| <a name="input_resource_tags"></a> [resource\_tags](#input\_resource\_tags) | Optional list of tags to be added to created SCC WP instance. | `list(string)` | `[]` | no |
| <a name="input_scc_wp_service_plan"></a> [scc\_wp\_service\_plan](#input\_scc\_wp\_service\_plan) | IBM service pricing plan. | `string` | `"free-trial"` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_api_endpoint"></a> [api\_endpoint](#output\_api\_endpoint) | API endpoint. |
| <a name="output_crn"></a> [crn](#output\_crn) | CRN of created SCC WP instance. |
| <a name="output_id"></a> [id](#output\_id) | ID of created SCC WP instance. |
| <a name="output_ingestion_endpoint"></a> [ingestion\_endpoint](#output\_ingestion\_endpoint) | Ingestion endpoint. |
| <a name="output_name"></a> [name](#output\_name) | Name of created SCC WP instance. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- Leave this section as is so that your module has a link to local development environment set up steps for contributors to follow -->
## Contributing

You can report issues and request features for this module in GitHub issues in the module repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.
