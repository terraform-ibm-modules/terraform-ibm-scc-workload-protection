########################################################################################################################
# Common variables
########################################################################################################################

variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API key to deploy resources."
  sensitive   = true
}

variable "existing_resource_group_name" {
  type        = string
  description = "The name of a an existing resource group in which to provision resources to."
  default     = "Default"
}

variable "existing_monitoring_crn" {
  type        = string
  nullable    = true
  default     = null
  description = "The CRN of an IBM Cloud Monitoring instance to to send Workload Protection data. If no value passed, metrics are sent to the instance associated to the container's location unless otherwise specified in the Metrics Router service configuration."
}

variable "prefix" {
  type        = string
  description = "The prefix to add to all resources that this solution creates (e.g `prod`, `test`, `dev`). To not use any prefix value, you can set this value to `null` or an empty string."
  default     = "test"
}

variable "provider_visibility" {
  description = "Set the visibility value for the IBM terraform provider. Supported values are `public`, `private`, `public-and-private`. [Learn more](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/guides/custom-service-endpoints)."
  type        = string
  default     = "public"

  validation {
    condition     = contains(["public", "private", "public-and-private"], var.provider_visibility)
    error_message = "Invalid visibility option. Allowed values are 'public', 'private', or 'public-and-private'."
  }
}

########################################################################################################################
# SCC variables
########################################################################################################################

variable "scc_workload_protection_instance_name" {
  description = "The name for the Workload Protection instance that is created by this solution. Must begin with a letter. If a prefix input variable is specified, the prefix is added to the name in the `<prefix>-<name>` format."
  type        = string
  default     = "scc-workload-protection"
}

variable "region" {
  type        = string
  default     = "us-south"
  description = "The region to provision Security and Compliance Center Workload Protection resources in."
  validation {
    condition = contains(["us-south",
      "us-east",
      "eu-de",
      "eu-es",
      "eu-gb",
      "jp-osa",
      "jp-tok",
      "br-sao",
      "ca-tor",
      "au-syd",
    ], var.region)
    error_message = "Invalid region selected. Allowed values are `us-south` ,`us-east`, `eu-de`, `eu-es`, `eu-gb`, `jp-osa`, `jp-tok`, `br-sao`, `ca-tor`, and `au-syd`."
  }
}

variable "scc_workload_protection_instance_tags" {
  type        = list(string)
  description = "The list of tags to add to the Workload Protection instance."
  default     = []
}

variable "scc_workload_protection_resource_key_tags" {
  type        = list(string)
  description = "The tags associated with the Workload Protection resource key."
  default     = []
}

variable "scc_workload_protection_access_tags" {
  type        = list(string)
  description = "A list of access tags to apply to the Workload Protection instance. Maximum length: 128 characters. Possible characters are A-Z, 0-9, spaces, underscores, hyphens, periods, and colons. [Learn more](https://cloud.ibm.com/docs/account?topic=account-tag&interface=ui#limits)."
  default     = []

  validation {
    condition = alltrue([
      for tag in var.scc_workload_protection_access_tags : can(regex("[\\w\\-_\\.]+:[\\w\\-_\\.]+", tag)) && length(tag) <= 128
    ])
    error_message = "Tags must match the regular expression \"[\\w\\-_\\.]+:[\\w\\-_\\.]+\", see https://cloud.ibm.com/docs/account?topic=account-tag&interface=ui#limits for more details"
  }
}

variable "scc_workload_protection_service_plan" {
  description = "The pricing plan for the Workload Protection instance service. Possible values: `free-trial`, `graduated-tier`."
  type        = string
  default     = "graduated-tier"
  validation {
    error_message = "Plan for Workload Protection instances can only be `free-trial` or `graduated-tier`."
    condition = contains(
      ["free-trial", "graduated-tier"],
      var.scc_workload_protection_service_plan
    )
  }
}

##############################################################
# App Config
##############################################################

variable "cspm_enabled" {
  description = "Enable Cloud Security Posture Management (CSPM) for the Workload Protection instance."
  type        = bool
  default     = true
}

variable "app_config_crn" {
  description = "The CRN of the App Config instance to use with the Workload Protection instance."
  type        = string
  default     = null
}

##############################################################
# Context-based restriction (CBR)
##############################################################
variable "cbr_rules" {
  type = list(object({
    description = string
    account_id  = string
    rule_contexts = list(object({
      attributes = optional(list(object({
        name  = string
        value = string
    }))) }))
    enforcement_mode = string
    tags = optional(list(object({
      name  = string
      value = string
    })), [])
    operations = optional(list(object({
      api_types = list(object({
        api_type_id = string
      }))
    })))
  }))
  description = "The list of context-based restriction rules to create for the instance.[Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-scc-workload-protection/blob/main/solutions/fully-configurable/cbr-rules.md)"
  default     = []
  # Validation happens in the rule module
}
