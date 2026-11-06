##############################################################################
# RT CSPM Module Variables
##############################################################################

variable "ibmcloud_api_key" {
  description = "IBM Cloud API key for authenticating with IBM Cloud services"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "IBM Cloud region where RT CSPM resources will be deployed"
  type        = string
  default     = "us-south"
}

variable "resource_group_id" {
  description = "The resource group ID in which RT CSPM resources will be provisioned"
  type        = string
}

variable "resource_tags" {
  description = "Optional list of tags to be added to RT CSPM resources"
  type        = list(string)
  default     = []
}

##############################################################################
# CDR Integration
##############################################################################

variable "use_cdr_infrastructure" {
  description = "Set to true when CDR is deployed alongside RT CSPM. RT CSPM then only creates the Activity Tracker and Event Notifications resources, and reuses CDR's COS bucket, Service ID, trusted profile, Code Engine project and app, COS subscription and CDR enablement. Must be known at plan time."
  type        = bool
  default     = false
  nullable    = false
}

variable "cdr_cos_instance_guid" {
  description = "GUID of the COS instance that holds the CDR bucket. Required when use_cdr_infrastructure is true."
  type        = string
  default     = null
  validation {
    condition     = var.use_cdr_infrastructure ? var.cdr_cos_instance_guid != null : true
    error_message = "cdr_cos_instance_guid must be provided when use_cdr_infrastructure is true."
  }
}

variable "cdr_cos_bucket_name" {
  description = "Name of the CDR COS bucket that Event Notifications will write to. Required when use_cdr_infrastructure is true."
  type        = string
  default     = null
  validation {
    condition     = var.use_cdr_infrastructure ? var.cdr_cos_bucket_name != null : true
    error_message = "cdr_cos_bucket_name must be provided when use_cdr_infrastructure is true."
  }
}

variable "cdr_cos_s3_endpoint" {
  description = "S3 endpoint of the CDR COS bucket (without https://). Required when use_cdr_infrastructure is true."
  type        = string
  default     = null
  validation {
    condition     = var.use_cdr_infrastructure ? var.cdr_cos_s3_endpoint != null : true
    error_message = "cdr_cos_s3_endpoint must be provided when use_cdr_infrastructure is true."
  }
}

##############################################################################
# App Configuration
##############################################################################

variable "app_config_crn" {
  description = "The CRN of an existing App Config instance to use with the SCC Workload Protection instance. Required if `cspm_enabled` is true. NOTE: Ensure the App Config instance has configuration aggregator enabled."
  type        = string

  validation {
    condition = anytrue([
      can(regex("^crn:(.*:){3}apprapp:(.*:){2}[0-9a-fA-F]{8}(?:-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}::$", var.app_config_crn)),
      var.app_config_crn == null,
    ])
    error_message = "The provided CRN is not a valid App Config CRN."
  }
}

##############################################################################
# Event Notifications
##############################################################################

variable "event_notifications_crn" {
  type        = string
  description = "The CRN of the existing Event Notifications instance to enable notifications for your App Configuration instance."

  validation {
    condition = anytrue([
      can(regex("^crn:(.*:){3}event-notifications:(.*:){2}[0-9a-fA-F]{8}(?:-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}::$", var.event_notifications_crn)),
      var.event_notifications_crn == null,
    ])
    error_message = "The provided Event Notifications instance CRN is not valid."
  }
}

variable "event_notifications_topic_name" {
  type        = string
  description = "The name of the Event Notifications topic to route App Configuration aggregator events."
}

variable "enable_topic_rule" {
  type        = bool
  description = "Whether to enable the rule on the Event Notifications topic source."
  default     = true
}

variable "event_type_filter" {
  type        = string
  description = "Event type filter for the Event Notifications topic rule."
  default     = "$.*"
}

variable "notification_filter" {
  type        = string
  description = "Notification filter JSONPath regex pattern for filtering App Configuration aggregator events."
  default     = "$.type =~ 'com.ibm.cloud.apprapp.config_aggregator.*'"
}

variable "event_notifications_destination_name" {
  type        = string
  description = "The name of the Event Notifications COS destination."
}

variable "event_notifications_subscription_name" {
  type        = string
  description = "The name of the Event Notifications COS subscription."
}


##############################################################################
# IAM Service ID
##############################################################################

variable "existing_service_id" {
  description = "ID of an existing IAM Service ID to reuse (e.g. from the CDR module). When set, no new Service ID is created."
  type        = string
  default     = null
}

variable "existing_service_id_apikey" {
  description = "API key of the existing Service ID to reuse (e.g. from the CDR module). Required when existing_service_id is set."
  type        = string
  default     = null
  sensitive   = true
  validation {
    condition     = var.existing_service_id != null ? var.existing_service_id_apikey != null : true
    error_message = "existing_service_id_apikey must be provided when existing_service_id is set."
  }
}

variable "iam_service_id_name" {
  description = "Name of the Service ID for the Code Engine application to send events to Workload Protection instance. Not used when existing_service_id is set."
  type        = string
  default     = null
  validation {
    condition     = var.use_cdr_infrastructure || var.existing_service_id != null ? true : var.iam_service_id_name != null
    error_message = "iam_service_id_name must be provided when existing_service_id is not set."
  }
}


variable "iam_service_policy_name" {
  description = "Name of the IAM Service policy having reader access for Container Registry. Not used when existing_service_id is set."
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
  default     = "rt-cspm-cos-instance"

  validation {
    condition     = var.existing_cos_instance_id == null && var.cos_instance_name == null ? false : true
    error_message = "existing_cos_instance_id and cos_instance_name cannot be both null."
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

variable "management_endpoint_type_for_bucket" {
  description = "The type of endpoint for the IBM terraform provider to manage the bucket. Possible values are `public`, `private`, or `direct`."
  type        = string
  default     = "public"
  validation {
    condition     = contains(["public", "private", "direct"], var.management_endpoint_type_for_bucket)
    error_message = "The value isn't valid. Possible values are `public`, `private`, or `direct`."
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
}

variable "atracker_route_name" {
  description = "Name of the Activity Tracker route."
  type        = string
}

variable "atracker_locations" {
  description = "List of locations to route Activity Tracker events from. Use ['*'] for all locations. Ensure that the route rule includes the `global` location in addition to your deployment region."
  type        = list(string)
  default     = ["global", "*"]
}

##############################################################################
# Trusted Profile
##############################################################################

variable "existing_trusted_profile_id" {
  description = "ID of an existing trusted profile to reuse (e.g. from the CDR module). When set, no new trusted profile is created."
  type        = string
  default     = null
}

variable "trusted_profile_name" {
  type        = string
  description = "The trusted profile for Workload Protection interaction with cloud object storage bucket. Not used when existing_trusted_profile_id is set."
  default     = null
  validation {
    condition     = var.use_cdr_infrastructure || var.existing_trusted_profile_id != null ? true : var.trusted_profile_name != null
    error_message = "trusted_profile_name must be provided when existing_trusted_profile_id is not set."
  }
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

variable "existing_ce_project_id" {
  description = "ID of an existing Code Engine project to reuse (e.g. from the CDR module). When set, no new project is created."
  type        = string
  default     = null
}

variable "ce_project_name" {
  description = "The name of the Code Engine project for RT CSPM. Not used when existing_ce_project_id is set."
  type        = string
  default     = null
  validation {
    condition     = var.use_cdr_infrastructure || var.existing_ce_project_id != null ? true : var.ce_project_name != null
    error_message = "ce_project_name must be provided when existing_ce_project_id is not set."
  }
}

variable "ce_app_name" {
  description = "The name of the Code Engine application for RT CSPM."
  type        = string
  default     = "ce-rt-cspm-app"
}

variable "rt_cspm_ce_app_image" {
  description = "The RT CSPM notification application image hosted in IBM Cloud Container Registry."
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
  default     = "rt-cspm-api-secret"
}

variable "ce_icr_secret_name" {
  description = "The name of the secret for pulling images from Container Registry."
  type        = string
  default     = "rt-cspm-icr-secret"
}

##############################################################################
# COS Event Subscription to Code Engine
##############################################################################

variable "subscription_name" {
  description = "The name of the COS event subscription to code engine."
  type        = string
  default     = "rt-cspm-cos-ce-subscription"
}

variable "install_required_binaries" {
  type        = bool
  default     = true
  description = "When set to true, a script will run to check if `jq`, the `ibmcloud` CLI, and the `code-engine` plugin exist on the runtime and if not attempt to download them from the public internet and install them to /tmp. Set to false to skip running this script."
  nullable    = false
}
