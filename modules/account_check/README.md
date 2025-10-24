# Account Check

This module determines whether a given IBM Cloud account is part of an `Enterprise` or is a `Standalone (Normal)` account.
It uses the IBM Cloud Enterprise Management API and can be easily integrated into Terraform configurations via the external data source.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_external"></a> [external](#requirement\_external) | 2.3.5 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [external_external.account_check](https://registry.terraform.io/providers/hashicorp/external/2.3.5/docs/data-sources/external) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ibmcloud_api_key"></a> [ibmcloud\_api\_key](#input\_ibmcloud\_api\_key) | The IBM Cloud platform API key needed to deploy IAM enabled resources. | `string` | n/a | yes |
| <a name="input_target_account_id"></a> [target\_account\_id](#input\_target\_account\_id) | The ID of the target account to check for type. | `string` | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_account_type"></a> [account\_type](#output\_account\_type) | The determined type of the IBM Cloud account. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
