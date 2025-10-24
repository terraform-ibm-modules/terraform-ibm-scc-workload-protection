variable "ibmcloud_api_key" {
  description = "The IBM Cloud platform API key needed to deploy IAM enabled resources."
  type        = string
  sensitive   = true
}

variable "target_account_id" {
  description = "The ID of the target account to check for type."
  type        = string
}
