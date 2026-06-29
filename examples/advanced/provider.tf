########################################################################################################################
# Provider config
########################################################################################################################

provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.region
}

# Data source to retrieve token details
data "ibm_iam_auth_token" "token_data" {
}

provider "restapi" {
  uri                   = "https:"
  write_returns_object  = true
  create_returns_object = false
  debug                 = false # set to true to show detailed logs, but use carefully as it might print sensitive values.
  headers = {
    Account       = local.account_id
    Authorization = data.ibm_iam_auth_token.token_data.iam_access_token
    Content-Type  = "application/json"
  }
}

provider "sysdig" {
  sysdig_secure_team_name = "Secure Operations"
  sysdig_secure_url       = "https://${var.region}.monitoring.cloud.ibm.com"
  ibm_secure_iam_url      = "https://iam.cloud.ibm.com"
  ibm_secure_instance_id  = module.scc_wp.guid
  ibm_secure_api_key      = var.ibmcloud_api_key
}
