
##############################################################################
# Input Variables
##############################################################################
variable "ibmcloud_api_key" {
  description = "The IBM Cloud platform API key needed to deploy IAM enabled resources."
  type        = string
  sensitive   = true
}

variable "prefix" {
  description = "Display name of the prefix for related resources"
  type        = string
  default     = "scc_wp"
}

variable "region" {
  description = "Name of the Region to deploy into"
  type        = string
  default     = "us-south"
}

variable "resource_group" {
  type        = string
  description = "An existing resource group name to use for this example, if unset a new resource group will be created"
  default     = null
}


variable "resource_tags" {
  type        = list(string)
  description = "Optional list of tags to be added to created resources"
  default     = []
}

variable "scc_wp_keys" {
  description = "Map of name, role for resource keys that you want to create for the SCC WP instance."
  type        = map(string)
  default = {
    "scc_wp_administrator" : "Administrator"
    "scc_wp_manager" : "Manager"
  }
}
