
##############################################################################
# Input Variables
##############################################################################

variable "region" {
  description = "IBM Cloud region where all resources will be deployed"
  type        = string
}

variable "resource_group_id" {
  description = "ID of resource group to use when creating the VPC and PAG"
  type        = string
}

variable "unique_name" {
  description = "A unique identifier used as a prefix when naming resources that will be provisioned. Must begin with a letter."
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

# ##############################################################################
# # SCC WP Instance Keys
# ##############################################################################

variable "scc_wp_key_role" {
  type        = string
  description = "Role assigned to provide the SCC WP Instance Key."
  default     = "Manager"

  validation {
    condition     = contains(["Administrator", "Manager", "Writer", "Reader"], var.scc_wp_key_role)
    error_message = "Allowed roles can be Administrator, Manager, Writer or Reader."
  }
}
