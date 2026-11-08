##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source                       = "terraform-ibm-modules/resource-group/ibm"
  version                      = "1.6.1"
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

##############################################################################
# Event Notifications
##############################################################################

module "event_notifications" {
  count   = var.existing_event_notifications_crn == null ? 1 : 0
  source  = "terraform-ibm-modules/event-notifications/ibm"
  version = "3.1.11"

  resource_group_id = module.resource_group.resource_group_id
  name              = "${var.prefix}-en"
  plan              = "standard"
  region            = var.region
  resource_tags     = var.resource_tags
  service_endpoints = "public-and-private"
}

locals {
  event_notifications_crn = var.existing_event_notifications_crn != null ? var.existing_event_notifications_crn : module.event_notifications[0].crn
  # Only used when this example also creates App Configuration (i.e. both existing CRNs are null)
  event_notifications_endpoint_url = var.existing_event_notifications_crn != null ? null : module.event_notifications[0].event_notifications_public_endpoint
}

##############################################################################
# App Configuration  (config aggregator + EN integration)
##############################################################################

module "app_config" {
  count   = var.existing_app_config_crn == null ? 1 : 0
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
  existing_event_notifications_instance_crn  = local.event_notifications_crn
  event_notifications_endpoint_url           = local.event_notifications_endpoint_url
  app_config_event_notifications_source_name = "${var.prefix}-appconfig-source"
}

locals {
  app_config_crn = var.existing_app_config_crn != null ? var.existing_app_config_crn : module.app_config[0].app_config_crn
}

##############################################################################
# SCC Workload Protection  (CSPM + RT CSPM enabled, CDR disabled)
##############################################################################

module "scc_wp" {
  depends_on = [module.app_config, module.event_notifications]

  source                                       = "../../"
  name                                         = "${var.prefix}-scc-wp"
  region                                       = var.region
  resource_group_id                            = module.resource_group.resource_group_id
  resource_tags                                = var.resource_tags
  cspm_enabled                                 = true
  app_config_crn                               = local.app_config_crn
  scc_workload_protection_trusted_profile_name = "${var.prefix}-wp-trusted-profile"

  # CDR disabled
  cdr_enabled = false

  # RT CSPM
  rt_cspm_enabled  = true
  ibmcloud_api_key = var.ibmcloud_api_key

  rt_cspm_event_notifications_crn               = local.event_notifications_crn
  rt_cspm_event_notifications_topic_name        = "${var.prefix}-rt-cspm-topic"
  rt_cspm_event_notifications_destination_name  = "${var.prefix}-rt-cspm-cos-destination"
  rt_cspm_event_notifications_subscription_name = "${var.prefix}-rt-cspm-cos-subscription"

  rt_cspm_atracker_target_name = "${var.prefix}-rt-cspm-at-target"
  rt_cspm_atracker_route_name  = "${var.prefix}-rt-cspm-at-route"
  rt_cspm_atracker_locations   = ["global", "*"]

  rt_cspm_cos_instance_name = "${var.prefix}-rt-cspm-cos"
  rt_cspm_cos_bucket_name   = "${var.prefix}-rt-cspm-bucket"

  rt_cspm_iam_service_id_name  = "${var.prefix}-rt-cspm-service-id"
  rt_cspm_trusted_profile_name = "${var.prefix}-rt-cspm-trusted-profile"
  rt_cspm_ce_project_name      = "${var.prefix}-rt-cspm-ce-project"
  rt_cspm_ce_app_name          = "${var.prefix}-rt-cspm-ce-app"
}
