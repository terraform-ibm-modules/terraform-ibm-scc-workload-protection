variable "region" {
  type = string
}

variable "prefix" {
  type = string
}

variable "resource_group" {
  type    = string
  default = null
}

variable "resource_tags" {
  type = list(string)
  default = []
}

variable "access_tags" {
  type = list(string)
  default = []
}

variable "enterprise_id" {
  type        = string
  description = "Enterprise ID for App Configuration aggregator"
}

variable "template_id" {
  type        = string
  description = "Trusted Profile Template ID"
}

variable "ibmcloud_api_key" {
  type        = string
  description = "IBM Cloud API key"
  sensitive   = true
}

