
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

variable "scc_wp_tags" {
  type        = list(string)
  description = "Optional list of tags to be added to created SCC WP instance."
  default     = []
}

##############################################################################
# SCC WP Instance Keys
##############################################################################

variable "scc_wp_keys" {
  description = "Map of name, role for resource keys that you want to create for the SCC WP instance."
  type        = map(string)
  default     = {}

  validation {
    condition     = alltrue([for name, role in var.scc_wp_keys : contains(["Administrator", "Manager", "Writer", "Reader"], role)])
    error_message = "Valid values for key roles are 'Administrator', 'Manager', 'Writer', and `Reader`"
  }
}
