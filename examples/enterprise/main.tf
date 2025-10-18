########################################################################################################################
# Resource group
########################################################################################################################

module "resource_group" {
  source                       = "terraform-ibm-modules/resource-group/ibm"
  version                      = "1.4.0"
  resource_group_name          = var.resource_group == null ? "${var.prefix}-rg" : null
  existing_resource_group_name = var.resource_group
}

########################################################################################################################
# App Config with config aggregator enabled
########################################################################################################################

module "app_config" {
  source                                                     = "terraform-ibm-modules/app-configuration/ibm"
  version                                                    = "1.12.5"
  region                                                     = var.region
  resource_group_id                                          = module.resource_group.resource_group_id
  app_config_plan                                            = "basic"
  app_config_name                                            = "${var.prefix}-app-config"
  app_config_tags                                            = var.resource_tags
  enable_config_aggregator                                   = true
  config_aggregator_trusted_profile_name                     = "${var.prefix}-app-config-tp"
  config_aggregator_resource_collection_regions              = ["all"] # supports passing list of regions, or "all" for all regions
  config_aggregator_enterprise_id                            = var.enterprise_id
  config_aggregator_enterprise_trusted_profile_template_name = "${var.prefix}-app-config-tp-template"
  config_aggregator_enterprise_account_group_ids_to_assign   = ["all"] # supports passing list of account groups. Use 'config_aggregator_enterprise_account_ids_to_assign' to pass individual accounts
}

########################################################################################################################
# SCC Workload Protection with CSPM enabled
########################################################################################################################

module "scc_wp" {
  source = "../.."
  # remove the above line and uncomment the below 2 lines to consume the module from the registry
  # source            = "terraform-ibm-modules/scc-workload-protection/ibm"
  # version           = "X.Y.Z" # Replace "X.Y.Z" with a release version to lock into a specific release
  name                                         = var.prefix
  region                                       = var.region
  resource_group_id                            = module.resource_group.resource_group_id
  resource_tags                                = var.resource_tags
  access_tags                                  = var.access_tags
  scc_wp_service_plan                          = "graduated-tier"
  cspm_enabled                                 = true
  app_config_crn                               = module.app_config.app_config_crn
  scc_workload_protection_trusted_profile_name = "${var.prefix}-scc-wp-tp"
}
