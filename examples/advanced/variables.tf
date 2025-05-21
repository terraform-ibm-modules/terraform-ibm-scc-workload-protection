
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
  default     = "scc-wp-adv"
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

variable "ibmcloud_resource_controller_api_endpoint" {
  description = "The URI of the Resource Controller service. This is used to update the Workload Protection instance to enable CSPM once the trusted profiles have been created."
  type        = string
  default     = "https://private.resource-controller.cloud.ibm.com"
}
