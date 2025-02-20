locals {
  prefix = var.prefix != null ? (var.prefix != "" ? var.prefix : null) : null

  scc_workload_protection_instance_name     = try("${local.prefix}-${var.scc_workload_protection_instance_name}", var.scc_workload_protection_instance_name)
  scc_workload_protection_resource_key_name = try("${local.prefix}-${var.scc_workload_protection_instance_name}-key", "${var.scc_workload_protection_instance_name}-key")
}

#######################################################################################################################
# Resource Group
#######################################################################################################################

module "resource_group" {
  source                       = "terraform-ibm-modules/resource-group/ibm"
  version                      = "1.1.6"
  resource_group_name          = var.use_existing_resource_group == false ? try("${local.prefix}-${var.resource_group_name}", var.resource_group_name) : null
  existing_resource_group_name = var.use_existing_resource_group == true ? var.resource_group_name : null
}

#######################################################################################################################
# SCC Workload Protection
#######################################################################################################################

module "scc_wp" {
  source                        = "../.."
  name                          = local.scc_workload_protection_instance_name
  region                        = var.scc_region
  resource_group_id             = module.resource_group.resource_group_id
  resource_tags                 = var.scc_workload_protection_instance_tags
  resource_key_name             = local.scc_workload_protection_resource_key_name
  resource_key_tags             = var.scc_workload_protection_resource_key_tags
  cloud_monitoring_instance_crn = var.existing_monitoring_crn
  access_tags                   = var.scc_workload_protection_access_tags
  scc_wp_service_plan           = var.scc_workload_protection_service_plan
}
