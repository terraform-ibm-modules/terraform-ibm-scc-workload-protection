########################################################################################################################
# Provider config
########################################################################################################################

provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.region
}

provider "sysdig" {
  sysdig_secure_team_name = "Secure Operations"
  sysdig_secure_url       = "https://${var.region}.monitoring.cloud.ibm.com"
  ibm_secure_iam_url      = "https://iam.cloud.ibm.com"
  ibm_secure_instance_id  = module.scc_wp.guid
  ibm_secure_api_key      = var.ibmcloud_api_key
}
