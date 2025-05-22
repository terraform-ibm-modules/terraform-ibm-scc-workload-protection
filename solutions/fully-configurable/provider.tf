########################################################################################################################
# Provider config
########################################################################################################################

provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.region
  visibility       = var.provider_visibility
}

data "ibm_iam_auth_token" "auth_token" {}

# Null resource replaced with restapi_object to enable CSPM
provider "restapi" {
  uri = var.ibmcloud_resource_controller_api_endpoint
  headers = {
    Authorization = data.ibm_iam_auth_token.auth_token.iam_access_token
  }
  write_returns_object = true
}
