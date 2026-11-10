variable "ibmcloud_api_key" {
  description = "IBM Cloud API key. Required for both CDR and RT CSPM."
  type        = string
  sensitive   = true
}

variable "region" {
  description = "IBM Cloud region where all resources will be deployed."
  type        = string
  default     = "us-south"
}

variable "prefix" {
  description = "Prefix prepended to the name of all resources created by this example."
  type        = string
  default     = "cdr-rt-cspm-test"
}

variable "resource_group" {
  type        = string
  description = "Name of an existing resource group to use. If null, a new resource group is created."
  default     = null
}

variable "resource_tags" {
  description = "List of tags to apply to all resources."
  type        = list(string)
  default     = []
}

variable "existing_app_config_crn" {
  type        = string
  description = "CRN of an existing App Configuration instance (enterprise plan, with config aggregator enabled). If null, a new instance is created. If set, `existing_event_notifications_crn` must also be set."
  default     = null
}

variable "existing_event_notifications_crn" {
  type        = string
  description = "CRN of an existing Event Notifications instance. If null, a new instance is created. If set, `existing_app_config_crn` must also be set."
  default     = null
}
