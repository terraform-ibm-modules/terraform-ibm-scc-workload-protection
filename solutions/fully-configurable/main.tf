#######################################################################################################################
# Locals
#######################################################################################################################

locals {
  prefix_is_valid = var.prefix != null || trimspace(var.prefix) != "" ? true : false

  # Compute names for SCC Workload Protection instance and trusted profile
  scc_workload_protection_instance_name        = local.prefix_is_valid ? "${var.prefix}-${var.scc_workload_protection_instance_name}" : var.scc_workload_protection_instance_name
  scc_workload_protection_resource_key_name    = local.prefix_is_valid ? "${var.prefix}-${var.scc_workload_protection_instance_name}-key" : "${var.scc_workload_protection_instance_name}-key"
  scc_workload_protection_trusted_profile_name = local.prefix_is_valid ? "${var.prefix}-${var.scc_workload_protection_trusted_profile_name}" : var.scc_workload_protection_trusted_profile_name
  config_service_trusted_profile_name          = local.prefix_is_valid ? "${var.prefix}-${var.config_service_trusted_profile_name}" : var.config_service_trusted_profile_name

  # Get account ID
  account_id = module.scc_wp.account_id
}

#######################################################################################################################
# Resource Group
#######################################################################################################################

module "resource_group" {
  source                       = "terraform-ibm-modules/resource-group/ibm"
  version                      = "1.2.0"
  existing_resource_group_name = var.existing_resource_group_name
}

#######################################################################################################################
# SCC Workload Protection
#######################################################################################################################

module "scc_wp" {
  source                        = "../.."
  name                          = local.scc_workload_protection_instance_name
  region                        = var.region
  resource_group_id             = module.resource_group.resource_group_id
  resource_tags                 = var.scc_workload_protection_instance_tags
  resource_key_name             = local.scc_workload_protection_resource_key_name
  resource_key_tags             = var.scc_workload_protection_resource_key_tags
  cloud_monitoring_instance_crn = var.existing_monitoring_crn
  access_tags                   = var.scc_workload_protection_access_tags
  scc_wp_service_plan           = var.scc_workload_protection_service_plan
  cbr_rules                     = var.cbr_rules
}

########################################################################################################################
# Beginning of Cloud Security Posture Management (CSPM) Configuration
########################################################################################################################
# SCC Workload Protection Trusted Profile
########################################################################################################################

# Create Trusted profile for SCC Workload Protection instance
module "trusted_profile_scc_wp" {
  count                       = var.cspm_enabled ? 1 : 0
  source                      = "terraform-ibm-modules/trusted-profile/ibm"
  version                     = "2.1.1"
  trusted_profile_name        = local.scc_workload_protection_trusted_profile_name
  trusted_profile_description = "Trusted Profile for SCC-WP to access App Config"

  trusted_profile_identity = {
    identifier    = module.scc_wp.crn
    identity_type = "crn"
  }

  trusted_profile_policies = [
    {
      roles = ["Service Configuration Reader", "Viewer", "Configuration Aggregator Reader"]
      resources = [{
        service = "apprapp"
      }]
      description = "App Config access"
    },
  ]

  trusted_profile_links = [{
    cr_type = "VSI"
    links = [{
      crn = module.scc_wp.crn
    }]
  }]
}

##############################################################
# App Config Trusted Profile
##############################################################

module "app_config_service_profile" {
  count                       = var.cspm_enabled ? 1 : 0
  source                      = "terraform-ibm-modules/trusted-profile/ibm"
  version                     = "2.1.1"
  trusted_profile_name        = local.config_service_trusted_profile_name
  trusted_profile_description = "Trusted Profile for App Config"

  trusted_profile_identity = {
    identifier    = var.app_config_crn
    identity_type = "crn"
  }

  trusted_profile_policies = [
    {
      roles = ["Viewer", "Service Configuration Reader"]
      resources = [{
        service = "All Account Management services"
      }]
      description = "All Account Management services"
    },
    {
      roles = ["Viewer", "Service Configuration Reader"]
      resources = [{
        service = "All Identity and Access enabled services"
      }]
      description = "All Identity and Access enabled services"
    },
  ]
}

##############################################################
# CRN Parser
##############################################################

module "crn_parser" {
  count   = var.cspm_enabled ? 1 : 0
  source  = "terraform-ibm-modules/common-utilities/ibm//modules/crn-parser"
  version = "1.1.0"
  crn     = var.app_config_crn
}

################################################################
# Config Service Instance
################################################################

resource "ibm_config_aggregator_settings" "config_aggregator_settings_instance" {
  count       = var.cspm_enabled ? 1 : 0
  instance_id = module.crn_parser[0].service_instance
  region      = var.region

  resource_collection_regions = ["all"]
  resource_collection_enabled = true
  trusted_profile_id          = module.app_config_service_profile[0].profile_id
}

################################################################
# IAM Auth Token
################################################################

data "ibm_iam_auth_token" "auth_token" {}

################################################################
# Enable CSPM for SCC Workload Protection instance
################################################################

# CSPM can only be enabled after the trusted profile exists,
# but profile can only exist after instance has been created
# hence we cannot directly enable CSPM in the instance creation
# and need to use a separate resource to enable it
resource "restapi_object" "enable_cspm" {
  count = var.cspm_enabled ? 1 : 0

  path = "/v2/resource_instances/${module.scc_wp.guid}"

  data = jsonencode({
    parameters = {
      enable_cspm = true
      target_accounts = [
        {
          account_id         = local.account_id
          config_crn         = var.app_config_crn
          trusted_profile_id = module.trusted_profile_scc_wp[0].profile_id
        }
      ]
    }
  })
  create_method = "PATCH" # Specify the HTTP method for updates

  depends_on = [
    module.scc_wp,
    module.trusted_profile_scc_wp
  ]
}
