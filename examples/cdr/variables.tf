variable "ibmcloud_api_key" {
  description = "The IBM Cloud API key"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "IBM Cloud region where resources will be deployed"
  type        = string
  default     = "us-south"
}

variable "prefix" {
  description = "Prefix to use for naming resources"
  type        = string
  default     = "cdr-test"
}

variable "resource_group" {
  type        = string
  description = "An existing resource group name to use for this example, if unset a new resource group will be created"
  default     = null
}

variable "resource_tags" {
  description = "List of tags to apply to resources"
  type        = list(string)
  default     = ["env:test", "purpose:cdr-testing"]
}

variable "cdr_atracker_target_name" {
  description = "Custom name for Activity Tracker target (optional)"
  type        = string
  default     = "cdr-test-target"
}

variable "cdr_atracker_route_name" {
  description = "Custom name for Activity Tracker route (optional)"
  type        = string
  default     = "cdr-test-route"
}
