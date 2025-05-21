########################################################################################################################
# App Config
########################################################################################################################

# Create new App Config instance
module "app_config" {
  source                   = "terraform-ibm-modules/app-configuration/ibm"
  version                  = "1.5.1"
  region                   = var.region
  resource_group_id        = module.resource_group.resource_group_id
  app_config_name          = "${var.prefix}-app-config"
  app_config_tags          = var.resource_tags
  enable_config_aggregator = true
}
