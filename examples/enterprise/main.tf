module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.1.6"

  resource_group_name          = var.resource_group == null ? "${var.prefix}-rg" : null
  existing_resource_group_name = var.resource_group
}


module "scc_wp" {
  source              = "../.."
  name                = var.prefix
  region              = var.region
  resource_group_id   = module.resource_group.resource_group_id
  resource_tags       = var.resource_tags
  access_tags         = var.access_tags
  scc_wp_service_plan = "graduated-tier"
}

module "app_config" {
  source            = "../../../terraform-ibm-app-configuration"
  region            = var.region
  resource_group_id = module.resource_group.resource_group_id
  app_config_name   = "${var.prefix}-app-config"
  app_config_tags   = var.resource_tags

  app_config_collections = [
    {
      name          = "${var.prefix}-collection"
      collection_id = "${var.prefix}-collection"
      description   = "Collection for ${var.prefix}"
    }
  ]
}

module "trusted_profiles" {
  source           = "../../../terraform-ibm-trusted-profile/examples/enterprise"
  region           = var.region
  app_config_crn   = module.app_config.app_config_crn
  scc_wp_crn       = module.scc_wp.crn
  ibmcloud_api_key = var.ibmcloud_api_key

  onboard_account_groups = true
}
module "config_aggregator" {
  source = "../../../terraform-ibm-app-configuration/modules/config_aggregator"

  app_config_instance_guid        = module.app_config.app_config_guid
  region                          = var.region
  enterprise_id                   = var.enterprise_id
  trusted_profile_template_id     = module.trusted_profiles.trusted_profile_template_id
  enterprise_trusted_profile_id   = module.trusted_profiles.trusted_profile_app_config_enterprise.profile_id
  general_trusted_profile_id      = module.trusted_profiles.trusted_profile_app_config_general.profile_id

}

