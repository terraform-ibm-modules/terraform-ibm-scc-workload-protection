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
  description = "The name of an existing resource group to provision the resources. If not provided the default resource group will be used."
  default     = null
}

variable "existing_monitoring_crn" {
  type        = string
  nullable    = true
  default     = null
  description = "To collect and analyze metrics and security data on hosts using both Monitoring and Workload Protection, pass the CRN of an existing IBM Cloud Monitoring instance to create a connection between instances. Both instances must be in the same region."

  validation {
    condition = anytrue([
      can(regex("^crn:(.*:){3}sysdig-monitor:${var.region}(.*:){1}[0-9a-fA-F]{8}(?:-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}::$", var.existing_monitoring_crn)),
      var.existing_monitoring_crn == null,
    ])
    error_message = "The provided Monitoring instance CRN in the input 'existing_monitoring_crn' in not valid. Please also ensure it is in the same region specified the 'region' input."
  }
}

variable "prefix" {
  type        = string
  nullable    = true
  description = "The prefix to be added to all resources created by this solution. To skip using a prefix, set this value to null or an empty string. The prefix must begin with a lowercase letter and may contain only lowercase letters, digits, and hyphens '-'. It should not exceed 16 characters, must not end with a hyphen('-'), and can not contain consecutive hyphens ('--'). Example: prod-scc-wp."

  validation {
    # - null and empty string is allowed
    # - Must not contain consecutive hyphens (--): length(regexall("--", var.prefix)) == 0
    # - Starts with a lowercase letter: [a-z]
    # - Contains only lowercase letters (a–z), digits (0–9), and hyphens (-)
    # - Must not end with a hyphen (-): [a-z0-9]
    condition = (var.prefix == null || var.prefix == "" ? true :
      alltrue([
        can(regex("^[a-z][-a-z0-9]*[a-z0-9]$", var.prefix)),
        length(regexall("--", var.prefix)) == 0
      ])
    )
    error_message = "Prefix must begin with a lowercase letter and may contain only lowercase letters, digits, and hyphens '-'. It must not end with a hyphen('-'), and cannot contain consecutive hyphens ('--')."
  }

  validation {
    # must not exceed 16 characters in length
    condition     = var.prefix == null || var.prefix == "" ? true : length(var.prefix) <= 16
    error_message = "Prefix must not exceed 16 characters."
  }
}

variable "provider_visibility" {
  description = "Set the visibility value for the IBM terraform provider. Supported values are `public`, `private`, `public-and-private`. [Learn more](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/guides/custom-service-endpoints)."
  type        = string
  default     = "private"

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
# CSPM
##############################################################

variable "cspm_enabled" {
  description = "Enable Cloud Security Posture Management (CSPM) for the Workload Protection instance. This will create a trusted profile associated with the SCC Workload Protection instance that has viewer / reader access to the App Config service and viewer access to the Enterprise service. [Learn more](https://cloud.ibm.com/docs/workload-protection?topic=workload-protection-about)."
  type        = bool
  default     = true
  nullable    = false
}

variable "app_config_crn" {
  description = "The CRN of an existing App Config instance to use with the SCC Workload Protection instance. Required if `cspm_enabled` is true. NOTE: Ensure the App Config instance has configuration aggregator enabled."
  type        = string
  default     = null
  validation {
    condition     = var.cspm_enabled ? var.app_config_crn != null : true
    error_message = "Cannot be `null` if CSPM is enabled."
  }
  validation {
    condition = anytrue([
      can(regex("^crn:(.*:){3}apprapp:(.*:){2}[0-9a-fA-F]{8}(?:-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}::$", var.app_config_crn)),
      var.app_config_crn == null,
    ])
    error_message = "The provided CRN is not a valid App Config CRN."
  }
}

variable "ibmcloud_resource_controller_api_endpoint" {
  description = "The IBM Cloud [resource controller endpoint](https://cloud.ibm.com/apidocs/resource-controller/resource-controller#endpoint-url) to use. This is used to update the Workload Protection instance to enable CSPM once the trusted profiles have been created."
  type        = string
  # TODO: When Schematics re-platform and add support for VPE, we can change this default to be "private.resource-controller.cloud.ibm.com"
  default = "https://private.us-south.resource-controller.cloud.ibm.com"
  validation {
    condition     = !(var.cspm_enabled && var.ibmcloud_resource_controller_api_endpoint == null)
    error_message = "This value cannot be `null` if `cspm_enabled` is set to `true`."
  }
}

variable "scc_workload_protection_trusted_profile_name" {
  description = "The name to give the trusted profile that is created by this module if `cspm_enabled` is `true. Must begin with a letter. If a prefix input variable is specified, the prefix is added to the name in the `<prefix>-<name>` format."
  type        = string
  default     = "workload-protection-trusted-profile"
  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9\\-_\\.]+$", var.scc_workload_protection_trusted_profile_name))
    error_message = "The trusted profile name must begin with a letter and can only contain letters, numbers, hyphens, underscores, and periods."
  }
  validation {
    condition     = !(var.cspm_enabled && var.scc_workload_protection_trusted_profile_name == null)
    error_message = "Cannot be `null` if `cspm_enabled` is `true`."
  }
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
