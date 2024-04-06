########################################################################################################################
# Resource group
########################################################################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.1.5"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

########################################################################################################################
# IBM Cloud monitoring instance
########################################################################################################################

module "cloud_monitoring" {
  source            = "terraform-ibm-modules/observability-instances/ibm//modules/cloud_monitoring"
  version           = "2.12.2"
  resource_group_id = module.resource_group.resource_group_id
  region            = var.region
  instance_name     = "${var.prefix}-cm"
}

########################################################################################################################
# SCC WP instance
########################################################################################################################

module "scc_wp" {
  source                        = "../.."
  name                          = var.prefix
  region                        = var.region
  resource_group_id             = module.resource_group.resource_group_id
  resource_tags                 = var.resource_tags
  access_tags                   = var.access_tags
  cloud_monitoring_instance_crn = module.cloud_monitoring.crn
}
