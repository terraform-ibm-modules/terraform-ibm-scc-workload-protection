locals {
  prefix_is_valid = var.prefix != null || trimspace(var.prefix) != "" ? true : false

  scc_workload_protection_instance_name     = local.prefix_is_valid ? "${var.prefix}-${var.scc_workload_protection_instance_name}" : var.scc_workload_protection_instance_name
  scc_workload_protection_resource_key_name = local.prefix_is_valid ? "${var.prefix}-${var.scc_workload_protection_instance_name}-key" : "${var.scc_workload_protection_instance_name}-key"
}

#######################################################################################################################
# Resource Group
#######################################################################################################################

module "resource_group" {
  source                       = "terraform-ibm-modules/resource-group/ibm"
  version                      = "1.2.0"
  existing_resource_group_name = var.existing_resource_group_name
}

##############################################################################
# Get Cloud Account ID
##############################################################################

data "ibm_iam_account_settings" "iam_account_settings" {
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
  cspm_enabled                  = var.cspm_enabled
  app_config_crn                = ibm_resource_instance.app_configuration_instance.crn
  trusted_profile_id            = ibm_iam_trusted_profile.workload_protection_profile[0].id
  account_id                    = data.ibm_iam_account_settings.iam_account_settings.account_id
}

########################################################################################################################
# Cloud Security Posture Management (CSPM)
########################################################################################################################

resource "ibm_resource_instance" "app_configuration_instance" {
  plan              = "basic"
  name              = "${var.prefix}-conf-agg"
  location          = var.region
  resource_group_id = module.resource_group.resource_group_id
  service           = "apprapp"
}

# Trusted Profile for Workload Protection
resource "ibm_iam_trusted_profile" "workload_protection_profile" {
  count = var.cspm_enabled ? 1 : 0
  name  = "${var.prefix}-workload-protection-trusted-profile"
}

# Trusted Profile Policiy for All Identify and Access enabled services for WP
resource "ibm_iam_trusted_profile_policy" "policy_workload_protection_apprapp" {
  count       = var.cspm_enabled ? 1 : 0
  profile_id  = ibm_iam_trusted_profile.workload_protection_profile[0].id
  roles       = ["Service Configuration Reader", "Viewer", "Configuration Aggregator Reader"]
  description = "apprapp"
  resources {
    service = "apprapp"
  }
}

# Trusted Profile Trust Relationship for Config Service
resource "ibm_iam_trusted_profile_identity" "trust_relationship_workload_protection" {
  count         = var.cspm_enabled ? 1 : 0
  identifier    = ibm_resource_instance.app_configuration_instance.crn
  identity_type = "crn"
  profile_id    = ibm_iam_trusted_profile.workload_protection_profile[0].id
  type          = "crn"
}

##############################################################
# App Config
##############################################################

module "crn_parser" {
  source  = "terraform-ibm-modules/common-utilities/ibm//modules/crn-parser"
  version = "1.1.0"
  crn     = ibm_resource_instance.app_configuration_instance.crn
}

# Trusted Profile for Config Service
resource "ibm_iam_trusted_profile" "config_service_profile" {
  count = var.cspm_enabled ? 1 : 0
  name  = "${var.prefix}-config-service-trusted-profile"
}

# Config Service Aggregator
resource "ibm_config_aggregator_settings" "config_aggregator_settings_instance" {
  count       = var.cspm_enabled ? 1 : 0
  instance_id = module.crn_parser.service_instance
  region      = var.region

  resource_collection_regions = ["all"]
  resource_collection_enabled = true
  trusted_profile_id          = ibm_iam_trusted_profile.config_service_profile[0].id
}

# Trusted Profile Policy for All Account Management services for Config Service
resource "ibm_iam_trusted_profile_policy" "policy_config_service_all_account" {
  count       = var.cspm_enabled ? 1 : 0
  profile_id  = ibm_iam_trusted_profile.config_service_profile[0].id
  roles       = ["Viewer", "Service Configuration Reader"]
  description = "All Account Management services"
  resources {
    service = "All Account Management services"
  }
}

# Trusted Profile Policiy for All Identify and Access enabled services for Config Service
resource "ibm_iam_trusted_profile_policy" "policy_config_service_all_identity" {
  count       = var.cspm_enabled ? 1 : 0
  profile_id  = ibm_iam_trusted_profile.config_service_profile[0].id
  roles       = ["Viewer", "Service Configuration Reader"]
  description = "All Identity and Access enabled services"
  resources {
    service = "All Identity and Access enabled services"
  }
}

# Trusted Profile Trust Relationship for Config Service
resource "ibm_iam_trusted_profile_identity" "trust_relationship_config_service" {
  count         = var.cspm_enabled ? 1 : 0
  identifier    = ibm_resource_instance.app_configuration_instance.crn
  identity_type = "crn"
  profile_id    = ibm_iam_trusted_profile.config_service_profile[0].id
  type          = "crn"
}
