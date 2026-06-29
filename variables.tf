
##############################################################################
# Input Variables
##############################################################################

variable "ibmcloud_api_key" {
  description = "IBM Cloud API key for authenticating with IBM Cloud services. Required for CDR functionality."
  type        = string
  sensitive   = true
  default     = null
  validation {
    condition     = var.cdr_enabled ? var.ibmcloud_api_key != null : true
    error_message = "ibmcloud_api_key must be provided when CDR is enabled."
  }
}

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
  description = "The name to give the SCC Workload Protection instance that will be provisioned by this module."
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
  description = "Add user resource tags to the SCC WP instance to organize, track, and manage costs. [Learn more](https://cloud.ibm.com/docs/account?topic=account-tag&interface=ui#tag-types)."
  default     = []
  validation {
    condition     = alltrue([for tag in var.resource_tags : can(regex("^[A-Za-z0-9 _\\-.:]{1,128}$", tag))])
    error_message = "Each resource tag must be 128 characters or less and may contain only A-Z, a-z, 0-9, spaces, underscore (_), hyphen (-), period (.), and colon (:)."
  }
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
  description = "Add access management tags to the SCC WP instance to control access. [Learn more](https://cloud.ibm.com/docs/account?topic=account-tag&interface=ui#create-access-console)."
  default     = []

  validation {
    condition = alltrue([
      for tag in var.access_tags : can(regex("[\\w\\-_\\.]+:[\\w\\-_\\.]+", tag)) && length(tag) <= 128
    ])
    error_message = "Tags must match the regular expression \"[\\w\\-_\\.]+:[\\w\\-_\\.]+\", see https://cloud.ibm.com/docs/account?topic=account-tag&interface=ui#limits for more details"
  }
}

variable "cloud_monitoring_instance_crn" {
  type        = string
  description = "To collect and analyze metrics and security data on hosts using both Monitoring and Workload Protection, pass the CRN of an existing IBM Cloud Monitoring instance to create the connection. Once the connection is created, the Monitoring instance CRN cannot be changed."
  default     = null

  validation {
    condition = anytrue([
      can(regex("^crn:(.*:){3}sysdig-monitor:${var.region}(.*:){1}[0-9a-fA-F]{8}(?:-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}::$", var.cloud_monitoring_instance_crn)),
      var.cloud_monitoring_instance_crn == null,
    ])
    error_message = "The provided Monitoring instance CRN in the input 'cloud_monitoring_instance_crn' in not valid. Please also ensure it is in the same region specified the 'region' input."
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

variable "scc_workload_protection_trusted_profile_name" {
  description = "The name to give the trusted profile that is created by this module if `cspm_enabled` is `true. Must begin with a letter."
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

variable "resource_controller_endpoint" {
  type        = string
  description = "The endpoint of the resource controller to manage the lifecycle of resources in an IBM cloud account."
  default     = "resource-controller.cloud.ibm.com"

  validation {
    condition     = can(regex("^(private.(us-east|us-south).)?resource-controller.cloud.ibm.com$", var.resource_controller_endpoint))
    error_message = "The endpoint must match the resource controller domain (e.g., resource-controller.cloud.ibm.com or its private us-east/us-south variants)."
  }
}

##############################################################
# Context-based restriction (CBR)
##############################################################

variable "cbr_rules" {
  type = list(object({
    description = string
    account_id  = string
    tags = optional(list(object({
      name  = string
      value = string
    })), [])
    rule_contexts = list(object({
      attributes = optional(list(object({
        name  = string
        value = string
    }))) }))
    enforcement_mode = string
  }))
  description = "The context-based restrictions rule to create. Only one rule is allowed."
  default     = []
  # Validation happens in the rule module
  validation {
    condition     = length(var.cbr_rules) <= 1
    error_message = "Only one CBR rule is allowed."
  }
}

##############################################################
# CDR (Cloud Detection and Response)
##############################################################

variable "cdr_enabled" {
  description = "Enable Cloud Detection and Response (CDR) for the Workload Protection instance. This will create infrastructure to forward Activity Tracker events to SCC-WP for compliance scanning. Requires CSPM to be enabled. [Learn more](https://cloud.ibm.com/docs/workload-protection?topic=workload-protection-about)."
  type        = bool
  default     = false
  nullable    = false
  validation {
    condition     = var.cdr_enabled ? var.cspm_enabled : true
    error_message = "CSPM must be enabled (cspm_enabled = true) when CDR is enabled."
  }
}

variable "cdr_iam_service_id_name" {
  description = "Name of the Service ID for the Code Engine application to send events to Workload Protection instance."
  type        = string
  default     = "cdr-ce-service-id"
}

variable "cdr_iam_service_policy_name" {
  description = "Name of the IAM Service policy having reader access for Container Registry."
  type        = string
  default     = "container-registry-reader"
}

variable "cdr_cos_instance_name" {
  description = "Name of the COS instance to be used as target for Activity Tracker Event Routing events."
  type        = string
  default     = "cdr-events-cos-instance"
}

variable "cdr_cos_bucket_name" {
  description = "Name of the COS bucket to be used as target for Activity Tracker Event Routing events"
  type        = string
  default     = "cdr-events-bucket"
}

variable "cdr_cos_bucket_storage_class" {
  description = "Storage class for the COS bucket."
  type        = string
  default     = "smart"
  validation {
    condition     = can(regex("^standard$|^vault$|^cold$|^smart$|^onerate_active", var.cdr_cos_bucket_storage_class))
    error_message = " The value isn't valid. Possible values are 'standard', 'vault', 'cold', 'smart', or 'onerate_active'."
  }
}

variable "cdr_cos_plan" {
  description = "Plan for the COS instance."
  type        = string
  default     = "standard"
  validation {
    condition     = contains(["standard", "lite"], var.cdr_cos_plan)
    error_message = "COS plan must be either 'standard' or 'lite'"
  }
}

variable "cdr_kms_encryption_enabled" {
  description = "Enable KMS encryption for the COS bucket"
  type        = bool
  default     = false
}

variable "cdr_kms_key_crn" {
  description = "CRN of the KMS key to use for bucket encryption. Required if kms_encryption_enabled is true"
  type        = string
  default     = null
  validation {
    condition     = var.cdr_kms_encryption_enabled ? var.cdr_kms_key_crn != null : true
    error_message = "kms_key_crn is required when kms_encryption_enabled is true"
  }
}

variable "cdr_skip_iam_authorization_policy" {
  description = "Set to true to skip the creation of an IAM authorization policy that permits the COS instance to read the encryption key from the KMS instance"
  type        = bool
  default     = true
  validation {
    condition     = var.cdr_kms_encryption_enabled ? var.cdr_skip_iam_authorization_policy != true : true
    error_message = "skip_iam_authorization_policy cannot be true when kms_encryption_enabled is true"
  }
}

variable "cdr_atracker_target_name" {
  description = "Name of the Activity Tracker target."
  type        = string
  default     = null
}

variable "cdr_atracker_route_name" {
  description = "Name of the Activity Tracker route."
  type        = string
  default     = null
}

variable "cdr_atracker_locations" {
  description = "List of locations to route Activity Tracker events from. Use ['*'] for all locations. Ensure that the route rule includes the `global` location in addition to your deployment region."
  type        = list(string)
  default     = ["global"]
}

variable "cdr_trusted_profile_name" {
  type        = string
  description = "The trusted profile for Workload Protection interaction with cloud object storage bucket."
  default     = "cdr-wp-trusted-profile"
}

variable "cdr_ce_project_name" {
  description = "The name of the Code Engine project for CDR."
  type        = string
  default     = "cdr-ce-project"
}

variable "cdr_ce_app_name" {
  description = "The name of the Code Engine application for CDR."
  type        = string
  default     = "ce-cdr-app"
}

variable "cdr_ce_app_image" {
  description = "The CDR notification application image hosted in IBM Cloud Container Registry."
  type        = string
  default     = "icr.io/ext/sysdig/cdr-notification-app:latest"

}

variable "cdr_ce_app_min_scale" {
  description = "Minimum number of instances for Code Engine app. Set to 1 to ensure the app is always ready to receive Object Storage events."
  type        = number
  default     = 1
  validation {
    condition     = var.cdr_ce_app_min_scale >= 1 && var.cdr_ce_app_min_scale <= 250
    error_message = "Minimum scale must be between 1 and 250"
  }
}

variable "cdr_ce_app_max_scale" {
  description = "Maximum number of instances for Code Engine app"
  type        = number
  default     = 10
  validation {
    condition     = var.cdr_ce_app_max_scale >= 1 && var.cdr_ce_app_max_scale <= 250
    error_message = "Maximum scale must be between 1 and 250"
  }
}

variable "cdr_ce_app_cpu" {
  description = "CPU limit for Code Engine app"
  type        = string
  default     = "0.125"
  validation {
    condition     = contains(["0.125", "0.25", "0.5", "1", "2", "4", "6", "8"], var.cdr_ce_app_cpu)
    error_message = "CPU limit must be one of: 0.125, 0.25, 0.5, 1, 2, 4, 6, 8"
  }
}

variable "cdr_ce_app_memory" {
  description = "Memory limit for Code Engine app"
  type        = string
  default     = "500M"
  validation {
    condition     = can(regex("^[0-9]+(M|G)$", var.cdr_ce_app_memory))
    error_message = "Memory limit must be in format like '500M' or '1G'"
  }
}

variable "cdr_ce_app_timeout" {
  description = "Request timeout in seconds for Code Engine app"
  type        = number
  default     = 60
  validation {
    condition     = var.cdr_ce_app_timeout >= 1 && var.cdr_ce_app_timeout <= 600
    error_message = "Timeout must be between 1 and 600 seconds"
  }
}

variable "cdr_ce_run_service_account" {
  description = "The name of the service account."
  type        = string
  default     = "default"
}

variable "cdr_ce_api_secret_name" {
  description = "The name of the secret for the Code Engine application."
  type        = string
  default     = "cdr-api-secret"
}

variable "cdr_ce_icr_secret_name" {
  description = "The name of the secret for pulling images from Container Registry."
  type        = string
  default     = "cdr-icr-secret"
}

variable "cdr_subscription_name" {
  description = "The name of the COS event subscription to code engine."
  type        = string
  default     = "cdr-cos-ce-subscriptions"
}

variable "cdr_install_required_binaries" {
  type        = bool
  default     = true
  description = "When set to true, a script will run to check if `jq`, the `ibmcloud` CLI, and the `code-engine` plugin exist on the runtime and if not attempt to download them from the public internet and install them to /tmp. Set to false to skip running this script."
  nullable    = false
}
