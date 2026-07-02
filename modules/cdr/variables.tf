##############################################################################
# CDR Module Variables
##############################################################################

variable "ibmcloud_api_key" {
  description = "IBM Cloud API key for authenticating with IBM Cloud services"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "IBM Cloud region where CDR resources will be deployed"
  type        = string
}

variable "resource_group_id" {
  description = "The resource group ID in which CDR resources will be provisioned"
  type        = string
}

variable "resource_tags" {
  description = "Optional list of tags to be added to CDR resources"
  type        = list(string)
  default     = []
}

##############################################################################
# IAM Service ID
##############################################################################

variable "iam_service_id_name" {
  description = "Name of the Service ID for the Code Engine application to send events to Workload Protection instance."
  type        = string
}


variable "iam_service_policy_name" {
  description = "Name of the IAM Service policy having reader access for Container Registry."
  type        = string
  default     = "container-registry-reader"
}

##############################################################################
# Cloud Object Storage Configuration
##############################################################################

variable "existing_cos_instance_id" {
  type        = string
  description = "Existing COS instance to pass in. If set to `null`, a new instance will be created."
  default     = null
}

variable "cos_instance_name" {
  description = "Name of the COS instance to be used as target for Activity Tracker Event Routing events."
  type        = string

  validation {
    condition     = var.existing_cos_instance_id == null && var.cos_instance_name == null ? false : true
    error_message = "var.existing_cos_instance_id and var.cos_instance_name cannot be both null."
  }
}

variable "cos_bucket_name" {
  description = "Name of the COS bucket to be used as target for Activity Tracker Event Routing events"
  type        = string
}

variable "cos_bucket_storage_class" {
  description = "Storage class for the COS bucket."
  type        = string
  default     = "smart"
  validation {
    condition     = can(regex("^standard$|^vault$|^cold$|^smart$|^onerate_active", var.cos_bucket_storage_class))
    error_message = " The value isn't valid. Possible values are 'standard', 'vault', 'cold', 'smart', or 'onerate_active'."
  }
}

variable "cos_plan" {
  description = "Plan for the COS instance."
  type        = string
  default     = "standard"
  validation {
    condition     = contains(["standard", "lite"], var.cos_plan)
    error_message = "COS plan must be either 'standard' or 'lite'"
  }
}

##############################################################################
# KMS Encryption Configuration
##############################################################################

variable "kms_encryption_enabled" {
  description = "Enable KMS encryption for the COS bucket"
  type        = bool
  default     = false
}

variable "kms_key_crn" {
  description = "CRN of the KMS key to use for bucket encryption. Required if kms_encryption_enabled is true"
  type        = string
  default     = null
  validation {
    condition     = var.kms_encryption_enabled ? var.kms_key_crn != null : true
    error_message = "kms_key_crn is required when kms_encryption_enabled is true"
  }
}

variable "skip_iam_authorization_policy" {
  description = "Set to true to skip the creation of an IAM authorization policy that permits the COS instance to read the encryption key from the KMS instance"
  type        = bool
  default     = true
  validation {
    condition     = var.kms_encryption_enabled ? var.skip_iam_authorization_policy != true : true
    error_message = "skip_iam_authorization_policy cannot be true when kms_encryption_enabled is true"
  }
}

##############################################################################
# Activity Tracker Configuration
##############################################################################

variable "atracker_target_name" {
  description = "Name of the Activity Tracker target."
  type        = string
  default     = null
}

variable "atracker_route_name" {
  description = "Name of the Activity Tracker route."
  type        = string
  default     = null
}

variable "atracker_locations" {
  description = "List of locations to route Activity Tracker events from. Use ['*'] for all locations. Ensure that the route rule includes the `global` location in addition to your deployment region."
  type        = list(string)
  default     = ["global"]
}

##############################################################################
# Trusted Profile
##############################################################################

variable "trusted_profile_name" {
  type        = string
  description = "The trusted profile for Workload Protection interaction with cloud object storage bucket."
}

##############################################################################
# SCC Workload Protection Configuration
##############################################################################

variable "target_account_id" {
  description = "The IBM Cloud account ID whose auditing events are being forwarded via Activity Tracker Event Routing."
  type        = string
}

variable "sysdig_environment_url" {
  description = "The sysdig workload protection environment URL (e.g. 'us-south.security-compliance-secure.cloud.ibm.com')."
  type        = string
}

variable "workload_protection_crn" {
  description = "The CRN of the SCC Workload Protection instance for trusted profile identity."
  type        = string
}

variable "workload_protection_guid" {
  description = "The GUID of the SCC Workload Protection instance for trusted profile identity."
  type        = string
}

##############################################################################
# Code Engine Configuration
##############################################################################

variable "ce_project_name" {
  description = "The name of the Code Engine project for CDR."
  type        = string
}

variable "ce_app_name" {
  description = "The name of the Code Engine application for CDR."
  type        = string
  default     = "ce-cdr-app"
}

variable "cdr_ce_app_image" {
  description = "The CDR notification application image hosted in IBM Cloud Container Registry."
  type        = string
  default     = "icr.io/ext/sysdig/cdr-notification-app:latest"

}

variable "ce_app_min_scale" {
  description = "Minimum number of instances for Code Engine app. Set to 1 to ensure the app is always ready to receive Object Storage events."
  type        = number
  default     = 1
  validation {
    condition     = var.ce_app_min_scale >= 1 && var.ce_app_min_scale <= 250
    error_message = "Minimum scale must be between 1 and 250"
  }
}

variable "ce_app_max_scale" {
  description = "Maximum number of instances for Code Engine app"
  type        = number
  default     = 10
  validation {
    condition     = var.ce_app_max_scale >= 1 && var.ce_app_max_scale <= 250
    error_message = "Maximum scale must be between 1 and 250"
  }
}

variable "ce_app_cpu" {
  description = "CPU limit for Code Engine app"
  type        = string
  default     = "0.125"
  validation {
    condition     = contains(["0.125", "0.25", "0.5", "1", "2", "4", "6", "8"], var.ce_app_cpu)
    error_message = "CPU limit must be one of: 0.125, 0.25, 0.5, 1, 2, 4, 6, 8"
  }
}

variable "ce_app_memory" {
  description = "Memory limit for Code Engine app"
  type        = string
  default     = "500M"
  validation {
    condition     = can(regex("^[0-9]+(M|G)$", var.ce_app_memory))
    error_message = "Memory limit must be in format like '500M' or '1G'"
  }
}

variable "ce_app_timeout" {
  description = "Request timeout in seconds for Code Engine app"
  type        = number
  default     = 60
  validation {
    condition     = var.ce_app_timeout >= 1 && var.ce_app_timeout <= 600
    error_message = "Timeout must be between 1 and 600 seconds"
  }
}

variable "ce_run_service_account" {
  description = "The name of the service account."
  type        = string
  default     = "default"
}

variable "ce_api_secret_name" {
  description = "The name of the secret for the Code Engine application."
  type        = string
  default     = "cdr-api-secret"
}

variable "ce_icr_secret_name" {
  description = "The name of the secret for pulling images from Container Registry."
  type        = string
  default     = "cdr-icr-secret"
}

##############################################################################
# COS Event Subscription to Code Engine
##############################################################################

variable "subscription_name" {
  description = "The name of the COS event subscription to code engine."
  type        = string
  default     = "cdr-cos-ce-subscription"
}

variable "install_required_binaries" {
  type        = bool
  default     = true
  description = "When set to true, a script will run to check if `jq`, the `ibmcloud` CLI, and the `code-engine` plugin exist on the runtime and if not attempt to download them from the public internet and install them to /tmp. Set to false to skip running this script."
  nullable    = false
}
