########################################################################################################################
# Provider config
########################################################################################################################

provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.region
  visibility       = var.provider_visibility
}

# Null resource replaced with restapi_object to enable CSPM
provider "restapi" {
  uri = "https://resource-controller.cloud.ibm.com"
  headers = {
    Authorization  = data.ibm_iam_auth_token.auth_token.iam_access_token
    "Content-Type" = "application/json"
  }
  write_returns_object = true
}
