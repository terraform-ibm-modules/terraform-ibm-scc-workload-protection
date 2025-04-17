variable "enterprise_id" {
  type        = string
  description = "The Enterprise ID used to scope the Config Aggregator or IAM templates."
}

variable "region" {
  type        = string
  description = "IBM Cloud region where resources will be deployed."
}

variable "prefix" {
  type        = string
  description = "Prefix used for naming all provisioned resources."
}

variable "resource_group" {
  type        = string
  default     = null
  description = "Name of an existing resource group to use. If null, a new one will be created using the prefix."
}

variable "resource_tags" {
  type        = list(string)
  default     = []
  description = "List of tags to apply to resources for tracking and organization."
}

variable "access_tags" {
  type        = list(string)
  default     = []
  description = "List of access tags to apply to resources for IAM policy scoping."
}


variable "ibmcloud_api_key" {
  type        = string
  description = "IBM Cloud API key used for authentication."
  sensitive   = true
}
