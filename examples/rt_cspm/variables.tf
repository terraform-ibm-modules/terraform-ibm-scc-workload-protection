variable "ibmcloud_api_key" {
  description = "IBM Cloud API key. Required for RT CSPM (Code Engine COS subscription management)."
  type        = string
  sensitive   = true
}

variable "region" {
  description = "IBM Cloud region where all resources will be deployed."
  type        = string
  default     = "eu-de"
}

variable "prefix" {
  description = "Prefix prepended to the name of all resources created by this example."
  type        = string
  default     = "cspm-test"
}

variable "resource_group" {
  type        = string
  description = "Name of an existing resource group to use. If null, a new resource group is created."
  default     = null
}

variable "resource_tags" {
  description = "List of tags to apply to all resources."
  type        = list(string)
  default     = ["env:test", "purpose:rt-cspm"]
}
