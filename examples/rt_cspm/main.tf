##############################################################################
# SCC Workload Protection — RT CSPM Only Example
#
# Enables Real-Time Cloud Security Posture Management (RT CSPM) without CDR.
#
# Flow:
#   IBM Cloud service actions
#          │
#          ▼
#   Activity Tracker Event Routing  (AT → AppConfig target)
#          │
#          ▼
#   App Configuration (config aggregator)
#          │
#          ▼
#   Event Notifications  (topic + COS destination)
#          │
#          ▼
#   Cloud Object Storage bucket  (EN notification archive)
#          │
#          ▼
#   Code Engine app  (COS event subscription → SCC-WP ingestion webhook)
#
# Resources created by this example:
#   • Resource group (new or existing)
#   • App Configuration instance  (config aggregator + EN integration)
#   • Event Notifications instance
#   • SCC Workload Protection instance  (CSPM + RT CSPM enabled, CDR disabled)
#     ├── AT app_config target + route
#     ├── S2S policy: AT → AppConfig
#     ├── EN topic (AppConfig aggregator filter)
#     ├── COS instance + bucket  (EN notification archive)
#     ├── S2S policy: EN → COS
#     ├── EN COS destination + subscription
#     ├── IAM Service ID + API key
#     ├── Trusted profile (WP → COS bucket)
#     ├── Code Engine project + app
#     └── COS event subscription → CE app
##############################################################################

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
  source  = "terraform-ibm-modules/event-notifications/ibm"
  version = "2.12.40"

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
  version = "1.18.6"

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
  app_config_crn                               = module.app_config.app_config_crn
  scc_workload_protection_trusted_profile_name = "${var.prefix}-wp-trusted-profile"

  # CDR disabled
  cdr_enabled = false

  # RT CSPM
  rt_cspm_enabled  = true
  ibmcloud_api_key = var.ibmcloud_api_key

  rt_cspm_event_notifications_crn               = module.event_notifications.crn
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
