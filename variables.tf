
##############################################################################
# Input Variables
##############################################################################

variable "region" {
  description = "IBM Cloud region where all resources will be deployed"
  type        = string
  default     = "us-south"
}

variable "resource_group_id" {
  description = "The resource group ID where resources will be provisioned."
  type        = string
}

variable "name" {
  description = "A identifier used as a prefix when naming resources that will be provisioned. Must begin with a letter."
  type        = string
}

##############################################################################
# Security and Compliance Center Workload Protection
##############################################################################

variable "scc_wp_service_plan" {
  description = "IBM service pricing plan."
  type        = string
  default     = "free-trial"
  validation {
    error_message = "Plan for SCC Workload Protection instances can only be `free-trial` or `graduated-tier`."
    condition = contains(
      ["free-trial", "graduated-tier"],
      var.scc_wp_service_plan
    )
  }
}

variable "resource_tags" {
  type        = list(string)
  description = "Optional list of tags to be added to created SCC WP instance."
  default     = []
}

variable "resource_key_name" {
  type        = string
  description = "The name to give the IBM Cloud SCC WP resource key."
  default     = "SCCWPManagerKey"
}

variable "resource_key_tags" {
  type        = list(string)
  description = "Tags associated with the IBM Cloud SCC WP resource key."
  default     = []
}

variable "access_tags" {
  type        = list(string)
  description = "A list of access tags to apply to the SCC WP instance created by the module. For more information, see https://cloud.ibm.com/docs/account?topic=account-access-tags-tutorial."
  default     = []

  validation {
    condition = alltrue([
      for tag in var.access_tags : can(regex("[\\w\\-_\\.]+:[\\w\\-_\\.]+", tag)) && length(tag) <= 128
    ])
    error_message = "Tags must match the regular expression \"[\\w\\-_\\.]+:[\\w\\-_\\.]+\", see https://cloud.ibm.com/docs/account?topic=account-tag&interface=ui#limits for more details"
  }
}
