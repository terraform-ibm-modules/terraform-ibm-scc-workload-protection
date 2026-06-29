#######################################################################################################################
# Locals
#######################################################################################################################

locals {
  prefix = var.prefix != null ? trimspace(var.prefix) != "" ? "${var.prefix}-" : "" : ""

  # Compute names for SCC Workload Protection instance and trusted profile
  scc_workload_protection_instance_name        = "${local.prefix}${var.scc_workload_protection_instance_name}"
  scc_workload_protection_resource_key_name    = "${local.prefix}${var.scc_workload_protection_instance_name}-key"
  scc_workload_protection_trusted_profile_name = "${local.prefix}${var.scc_workload_protection_trusted_profile_name}"
}

#######################################################################################################################
# Resource Group
#######################################################################################################################

module "resource_group" {
  source                       = "terraform-ibm-modules/resource-group/ibm"
  version                      = "1.6.1"
  existing_resource_group_name = var.existing_resource_group_name
}

#######################################################################################################################
# SCC Workload Protection
#######################################################################################################################

locals {
  # TODO: When Schematics re-platform and add support for VPE, we can change this default to be "private.resource-controller.cloud.ibm.com"
  resource_controller_endpoint = var.provider_visibility == "private" ? "private.us-south.${var.ibmcloud_resource_controller_api_endpoint}" : var.ibmcloud_resource_controller_api_endpoint
}

module "scc_wp" {
  source                                       = "../.."
  name                                         = local.scc_workload_protection_instance_name
  region                                       = var.region
  resource_group_id                            = module.resource_group.resource_group_id
  resource_tags                                = var.scc_workload_protection_instance_tags
  resource_key_name                            = local.scc_workload_protection_resource_key_name
  resource_key_tags                            = var.scc_workload_protection_resource_key_tags
  cloud_monitoring_instance_crn                = var.existing_monitoring_crn
  access_tags                                  = var.scc_workload_protection_access_tags
  scc_wp_service_plan                          = var.scc_workload_protection_service_plan
  cbr_rules                                    = var.cbr_rules
  cspm_enabled                                 = var.cspm_enabled
  app_config_crn                               = var.app_config_crn
  scc_workload_protection_trusted_profile_name = local.scc_workload_protection_trusted_profile_name
  resource_controller_endpoint                 = local.resource_controller_endpoint
}
