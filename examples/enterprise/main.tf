########################################################################################################################
# Resource group
########################################################################################################################

module "resource_group" {
  source                       = "terraform-ibm-modules/resource-group/ibm"
  version                      = "1.2.0"
  resource_group_name          = var.resource_group == null ? "${var.prefix}-rg" : null
  existing_resource_group_name = var.resource_group
}

########################################################################################################################
# SCC Workload Protection
########################################################################################################################

# Create SCC Workload Protection instance
module "scc_wp" {
  source                = "../.."
  name                  = var.prefix
  region                = var.region
  resource_group_id     = module.resource_group.resource_group_id
  resource_tags         = var.resource_tags
  access_tags           = var.access_tags
  scc_wp_service_plan   = "graduated-tier"
  is_enterprise_account = true
}

########################################################################################################################
# App Config
########################################################################################################################

# Create new App Config instance
module "app_config" {
  source                          = "terraform-ibm-modules/app-configuration/ibm"
  version                         = "1.5.1"
  region                          = var.region
  resource_group_id               = module.resource_group.resource_group_id
  app_config_plan                 = "enterprise"
  app_config_name                 = "${var.prefix}-app-config"
  app_config_tags                 = var.resource_tags
  enable_config_aggregator        = true
  config_aggregator_enterprise_id = var.enterprise_id
}
