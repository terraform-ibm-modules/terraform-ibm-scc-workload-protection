##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.4.7"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

########################################################################################################################
# App Config
########################################################################################################################

# Create new App Config instance
module "app_config" {
  source                                 = "terraform-ibm-modules/app-configuration/ibm"
  version                                = "1.14.8"
  region                                 = var.region
  resource_group_id                      = module.resource_group.resource_group_id
  app_config_name                        = "${var.prefix}-app-config"
  app_config_tags                        = var.resource_tags
  enable_config_aggregator               = true
  app_config_plan                        = "basic"
  config_aggregator_trusted_profile_name = "${var.prefix}-app-config-tp"
}
