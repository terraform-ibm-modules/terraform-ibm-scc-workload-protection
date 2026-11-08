##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.6.1"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

##############################################################################
# Event Notifications
##############################################################################

module "event_notifications" {
  source  = "terraform-ibm-modules/event-notifications/ibm"
  version = "3.1.12"

  resource_group_id = module.resource_group.resource_group_id
  name              = "${var.prefix}-en"
  plan              = "standard"
  region            = var.region
  resource_tags     = var.resource_tags
  service_endpoints = "public-and-private"
}

##############################################################################
# App Configuration  (config aggregator + EN integration)
##############################################################################

module "app_config" {
  source  = "terraform-ibm-modules/app-configuration/ibm"
  version = "1.20.5"

  region            = var.region
  resource_group_id = module.resource_group.resource_group_id
  app_config_plan   = "enterprise"
  app_config_name   = "${var.prefix}-app-config"
  resource_tags     = var.resource_tags

  # Config aggregator — required for RT CSPM
  enable_config_aggregator               = true
  config_aggregator_trusted_profile_name = "${var.prefix}-app-config-tp"

  # EN integration — creates AppConfig → EN S2S policy and source registration
  enable_event_notifications                 = true
  existing_event_notifications_instance_crn  = module.event_notifications.crn
  event_notifications_endpoint_url           = module.event_notifications.event_notifications_public_endpoint
  app_config_event_notifications_source_name = "${var.prefix}-appconfig-source"
}
