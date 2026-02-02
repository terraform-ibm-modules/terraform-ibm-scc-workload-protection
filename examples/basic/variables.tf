
##############################################################################
# Input Variables
##############################################################################
variable "ibmcloud_api_key" {
  description = "The IBM Cloud platform API key needed to deploy IAM enabled resources."
  type        = string
  sensitive   = true
}

variable "app_config_crn" {
  description = "The CRN of an existing App Config instance to use with the SCC Workload Protection instance. Required if `cspm_enabled` is true. NOTE: Ensure the App Config instance has configuration aggregator enabled."
  type        = string
}

variable "prefix" {
  description = "Display name of the prefix for related resources"
  type        = string
  default     = "scc-wp-2"
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

variable "access_tags" {
  type        = list(string)
  description = "Optional list of access management tags to add to the SCC WP instance"
  default     = []
}
