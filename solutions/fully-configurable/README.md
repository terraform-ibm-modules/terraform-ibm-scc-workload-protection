# Cloud automation for Security and Compliance Center Workload Protection

This solution supports provisioning and configuring the following infrastructure:

- A Security and Compliance Center Workload Protection instance.

:exclamation: **Important:** This solution is not intended to be called by other modules because it contains a provider configuration and is not compatible with the `for_each`, `count`, and `depends_on` arguments. For more information, see [Providers Within Modules](https://developer.hashicorp.com/terraform/language/modules/develop/providers).

![Workload Protection](./reference-architecture/scc.svg)

### Known issues
#### restapi_object.enable_cspm resource always identified for creation
There is currently a [known issue](https://github.com/terraform-ibm-modules/terraform-ibm-scc-workload-protection/issues/243) where you will always see the `restapi_object.enable_cspm` resource included in the terraform plan for creation, even after it has already been applied. It is safe to proceed with this apply and will be a no-op if the resource has already been applied.

<!-- Below content is automatically populated via pre-commit hook -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | 1.79.2 |
| <a name="requirement_restapi"></a> [restapi](#requirement\_restapi) | 2.0.1 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | terraform-ibm-modules/resource-group/ibm | 1.2.1 |
| <a name="module_scc_wp"></a> [scc\_wp](#module\_scc\_wp) | ../.. | n/a |

### Resources

| Name | Type |
|------|------|
| [ibm_iam_auth_token.auth_token](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.79.2/docs/data-sources/iam_auth_token) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_config_crn"></a> [app\_config\_crn](#input\_app\_config\_crn) | The CRN of an existing App Config instance to use with the SCC Workload Protection instance. Required if `cspm_enabled` is true. NOTE: Ensure the App Config instance has configuration aggregator enabled. | `string` | `null` | no |
| <a name="input_cbr_rules"></a> [cbr\_rules](#input\_cbr\_rules) | The list of context-based restriction rules to create for the instance.[Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-scc-workload-protection/blob/main/solutions/fully-configurable/cbr-rules.md) | <pre>list(object({<br/>    description = string<br/>    account_id  = string<br/>    rule_contexts = list(object({<br/>      attributes = optional(list(object({<br/>        name  = string<br/>        value = string<br/>    }))) }))<br/>    enforcement_mode = string<br/>    tags = optional(list(object({<br/>      name  = string<br/>      value = string<br/>    })), [])<br/>    operations = optional(list(object({<br/>      api_types = list(object({<br/>        api_type_id = string<br/>      }))<br/>    })))<br/>  }))</pre> | `[]` | no |
| <a name="input_cspm_enabled"></a> [cspm\_enabled](#input\_cspm\_enabled) | Enable Cloud Security Posture Management (CSPM) for the Workload Protection instance. This will create a trusted profile associated with the SCC Workload Protection instance that has viewer / reader access to the App Config service and viewer access to the Enterprise service. [Learn more](https://cloud.ibm.com/docs/workload-protection?topic=workload-protection-about). | `bool` | `true` | no |
| <a name="input_existing_monitoring_crn"></a> [existing\_monitoring\_crn](#input\_existing\_monitoring\_crn) | The CRN of an IBM Cloud Monitoring instance to to send Workload Protection data. If no value passed, metrics are sent to the instance associated to the container's location unless otherwise specified in the Metrics Router service configuration. | `string` | `null` | no |
| <a name="input_existing_resource_group_name"></a> [existing\_resource\_group\_name](#input\_existing\_resource\_group\_name) | The name of a an existing resource group in which to provision resources to. | `string` | `"Default"` | no |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud\_api\_key](#input\_ibmcloud\_api\_key) | The IBM Cloud API key to deploy resources. | `string` | n/a | yes |
| <a name="input_ibmcloud_resource_controller_api_endpoint"></a> [ibmcloud\_resource\_controller\_api\_endpoint](#input\_ibmcloud\_resource\_controller\_api\_endpoint) | The IBM Cloud [resource controller endpoint](https://cloud.ibm.com/apidocs/resource-controller/resource-controller#endpoint-url) to use. This is used to update the Workload Protection instance to enable CSPM once the trusted profiles have been created. | `string` | `"https://private.us-south.resource-controller.cloud.ibm.com"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | The prefix to be added to all resources created by this solution. To skip using a prefix, set this value to null or an empty string. The prefix must begin with a lowercase letter and may contain only lowercase letters, digits, and hyphens '-'. It should not exceed 16 characters, must not end with a hyphen('-'), and can not contain consecutive hyphens ('--'). Example: prod-scc-wp. | `string` | n/a | yes |
| <a name="input_provider_visibility"></a> [provider\_visibility](#input\_provider\_visibility) | Set the visibility value for the IBM terraform provider. Supported values are `public`, `private`, `public-and-private`. [Learn more](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/guides/custom-service-endpoints). | `string` | `"private"` | no |
| <a name="input_region"></a> [region](#input\_region) | The region to provision Security and Compliance Center Workload Protection resources in. | `string` | `"us-south"` | no |
| <a name="input_scc_workload_protection_access_tags"></a> [scc\_workload\_protection\_access\_tags](#input\_scc\_workload\_protection\_access\_tags) | A list of access tags to apply to the Workload Protection instance. Maximum length: 128 characters. Possible characters are A-Z, 0-9, spaces, underscores, hyphens, periods, and colons. [Learn more](https://cloud.ibm.com/docs/account?topic=account-tag&interface=ui#limits). | `list(string)` | `[]` | no |
| <a name="input_scc_workload_protection_instance_name"></a> [scc\_workload\_protection\_instance\_name](#input\_scc\_workload\_protection\_instance\_name) | The name for the Workload Protection instance that is created by this solution. Must begin with a letter. If a prefix input variable is specified, the prefix is added to the name in the `<prefix>-<name>` format. | `string` | `"scc-workload-protection"` | no |
| <a name="input_scc_workload_protection_instance_tags"></a> [scc\_workload\_protection\_instance\_tags](#input\_scc\_workload\_protection\_instance\_tags) | The list of tags to add to the Workload Protection instance. | `list(string)` | `[]` | no |
| <a name="input_scc_workload_protection_resource_key_tags"></a> [scc\_workload\_protection\_resource\_key\_tags](#input\_scc\_workload\_protection\_resource\_key\_tags) | The tags associated with the Workload Protection resource key. | `list(string)` | `[]` | no |
| <a name="input_scc_workload_protection_service_plan"></a> [scc\_workload\_protection\_service\_plan](#input\_scc\_workload\_protection\_service\_plan) | The pricing plan for the Workload Protection instance service. Possible values: `free-trial`, `graduated-tier`. | `string` | `"graduated-tier"` | no |
| <a name="input_scc_workload_protection_trusted_profile_name"></a> [scc\_workload\_protection\_trusted\_profile\_name](#input\_scc\_workload\_protection\_trusted\_profile\_name) | The name to give the trusted profile that is created by this module if `cspm_enabled` is `true. Must begin with a letter. If a prefix input variable is specified, the prefix is added to the name in the `<prefix>-<name>` format.` | `string` | `"workload-protection-trusted-profile"` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_resource_group_id"></a> [resource\_group\_id](#output\_resource\_group\_id) | Resource group ID |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | Resource group name |
| <a name="output_scc_workload_protection_access_key"></a> [scc\_workload\_protection\_access\_key](#output\_scc\_workload\_protection\_access\_key) | SCC Workload Protection access key |
| <a name="output_scc_workload_protection_api_endpoint"></a> [scc\_workload\_protection\_api\_endpoint](#output\_scc\_workload\_protection\_api\_endpoint) | SCC Workload Protection API endpoint |
| <a name="output_scc_workload_protection_crn"></a> [scc\_workload\_protection\_crn](#output\_scc\_workload\_protection\_crn) | SCC Workload Protection instance CRN |
| <a name="output_scc_workload_protection_id"></a> [scc\_workload\_protection\_id](#output\_scc\_workload\_protection\_id) | SCC Workload Protection instance ID |
| <a name="output_scc_workload_protection_ingestion_endpoint"></a> [scc\_workload\_protection\_ingestion\_endpoint](#output\_scc\_workload\_protection\_ingestion\_endpoint) | SCC Workload Protection instance ingestion endpoint |
| <a name="output_scc_workload_protection_name"></a> [scc\_workload\_protection\_name](#output\_scc\_workload\_protection\_name) | SCC Workload Protection instance name |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
