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
# App Configuration  (config aggregator + EN integration)
# Required by both CSPM and RT CSPM.
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
# Event Notifications
# Required by RT CSPM to receive AppConfig aggregator change events.
##############################################################################

module "event_notifications" {
  count   = var.existing_event_notifications_crn == null ? 1 : 0
  source  = "terraform-ibm-modules/event-notifications/ibm"
  version = "3.1.12"

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
# SCC Workload Protection  (CSPM + CDR + RT CSPM all enabled)
#
# The root module wires CDR outputs → RT CSPM existing_* inputs automatically,
# so the Service ID, Trusted Profile, and Code Engine project are shared.
##############################################################################

module "scc_wp" {
  depends_on        = [module.app_config, module.event_notifications]
  source            = "../../"
  name              = "${var.prefix}-scc-wp"
  region            = var.region
  resource_group_id = module.resource_group.resource_group_id
  resource_tags     = var.resource_tags

  # CSPM — prerequisite for both CDR and RT CSPM
  cspm_enabled                                 = true
  app_config_crn                               = local.app_config_crn
  scc_workload_protection_trusted_profile_name = "${var.prefix}-wp-trusted-profile"

  ##########################################################################
  # CDR
  ##########################################################################
  cdr_enabled      = true
  ibmcloud_api_key = var.ibmcloud_api_key

  cdr_cos_instance_name                   = "${var.prefix}-cdr-cos"
  cdr_cos_bucket_name                     = "${var.prefix}-cdr-events"
  cdr_cos_bucket_storage_class            = "smart"
  cdr_management_endpoint_type_for_bucket = "public"

  cdr_atracker_target_name = "${var.prefix}-cdr-at-target"
  cdr_atracker_route_name  = "${var.prefix}-cdr-at-route"
  cdr_atracker_locations   = ["global"]

  # Service ID, trusted profile, and CE project are created by CDR and
  # automatically reused by RT CSPM — no need to set them separately.
  cdr_iam_service_id_name  = "${var.prefix}-shared-service-id"
  cdr_trusted_profile_name = "${var.prefix}-shared-trusted-profile"
  cdr_ce_project_name      = "${var.prefix}-shared-ce-project"
  cdr_ce_app_name          = "${var.prefix}-cdr-ce-app"

  ##########################################################################
  # RT CSPM
  # Shared infrastructure (Service ID, Trusted Profile, CE project, COS
  # instance) is passed automatically from the CDR outputs by the root module.
  ##########################################################################
  rt_cspm_enabled = true

  rt_cspm_event_notifications_crn               = local.event_notifications_crn
  rt_cspm_event_notifications_topic_name        = "${var.prefix}-rt-cspm-topic"
  rt_cspm_event_notifications_destination_name  = "${var.prefix}-rt-cspm-cos-destination"
  rt_cspm_event_notifications_subscription_name = "${var.prefix}-rt-cspm-cos-subscription"

  rt_cspm_atracker_target_name = "${var.prefix}-rt-cspm-at-target"
  rt_cspm_atracker_route_name  = "${var.prefix}-rt-cspm-at-route"
  rt_cspm_atracker_locations   = ["global", "*"]
}
