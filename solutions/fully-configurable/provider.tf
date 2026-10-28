########################################################################################################################
# Provider config
########################################################################################################################

provider "ibm" {
  ibmcloud_api_key      = var.ibmcloud_api_key
  region                = var.region
  visibility            = var.provider_visibility
  private_endpoint_type = (var.provider_visibility == "private" && var.region == "ca-mon") ? "vpe" : null
}

# The restapi provider is no longer used to enable CSPM, but Terraform still needs it
# configured to drop the old restapi_object.cspm from the state of existing deployments.
# It can be removed in a later release, once existing deployments have upgraded.
data "ibm_iam_auth_token" "auth_token" {}

provider "restapi" {
  uri = var.ibmcloud_resource_controller_api_endpoint
  headers = {
    Authorization = data.ibm_iam_auth_token.auth_token.iam_access_token
  }
  write_returns_object = true
}
