# Account Check

This module determines whether a given IBM Cloud account is part of an `ENTERPRISE` or is a `Standalone (ACCOUNT)` account.
It uses the IBM Cloud Enterprise Management API and can be easily integrated into Terraform configurations via the external data source.

### Prerequisites

This module utilizes an external script that relies on the following command-line tools being installed on the system where Terraform is executed:
- `jq`: A lightweight and flexible command-line JSON processor. It is required for parsing the input provided by the Terraform external data source.
- `curl`: A tool to transfer data with URLs, required for making API calls to the IBM Cloud Enterprise Management API.

### Usage
```hcl
module "account_type_check" {
  source            = "terraform-ibm-modules/scc-workload-protection/ibm//modules/account_check"
  target_account_id = <ACCOUNT_ID>
  iam_token         = "XXXXXXXXXXXXXX"  # pragma: allowlist secret
}
```

### Required IAM access policies

- Account Management
  - **Enterprise** service
      - `Viewer` platform access
  - **All Identity and Access enabled** services
      - `Viewer` platform access

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_external"></a> [external](#requirement\_external) | >= 2.3.5, <3.0.0 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [terraform_data.install_required_binaries](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [external_external.account_check](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_iam_token"></a> [iam\_token](#input\_iam\_token) | The IBM Cloud platform IAM token needed to authenticate deploy IAM enabled resources. | `string` | n/a | yes |
| <a name="input_install_required_binaries"></a> [install\_required\_binaries](#input\_install\_required\_binaries) | When set to true, a script will run to check if `jq` exist on the runtime and if not attempt to download it from the public internet and install it to /tmp. Set to false to skip running this script. | `bool` | `true` | no |
| <a name="input_target_account_id"></a> [target\_account\_id](#input\_target\_account\_id) | The ID of the target account to check for type. | `string` | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_account_type"></a> [account\_type](#output\_account\_type) | The determined type of the IBM Cloud account. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
