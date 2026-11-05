##############################################################################
# Activity Tracker Route and App Configuration Target for RT CSPM
##############################################################################

resource "ibm_atracker_target" "appconfig" {
  name        = var.atracker_target_name
  target_type = "app_config"
  appconfig_endpoint {
    target_crn = var.app_config_crn
  }

  # The target creation performs a test write to App Config, so the S2S
  # authorization must exist and have propagated first.
  depends_on = [time_sleep.wait_for_atracker_to_appconfig_auth_policy]
}

resource "ibm_atracker_route" "rt_cspm" {
  name = var.atracker_route_name
  rules {
    locations  = var.atracker_locations
    target_ids = [ibm_atracker_target.appconfig.id]
  }
}

##############################################################################
# S2S: Activity Tracker → App Configuration
# Allows AT to deliver events into the AppConfig config aggregator.
##############################################################################

locals {
  # Build the Sysdig ingestion URL from environment URL and the effective service ID.
  # Null when use_cdr_infrastructure is true (CDR owns the forwarding app and Service ID).
  rt_cspm_ingestion_endpoint = local.effective_service_id == null ? null : "https://${var.sysdig_environment_url}/api/cloudingestion/webhooks/ibm/v1/${local.effective_service_id}"
  app_config_guid            = module.app_config_crn_parser.service_instance
}

module "app_config_crn_parser" {
  source  = "terraform-ibm-modules/common-utilities/ibm//modules/crn-parser"
  version = "1.9.0"
  crn     = var.app_config_crn
}

resource "ibm_iam_authorization_policy" "atracker_to_appconfig" {
  source_service_name         = "atracker"
  target_service_name         = "apprapp"
  target_resource_instance_id = local.app_config_guid
  roles                       = ["Configuration Update Reporter"]
  description                 = "Allows Activity Tracker to write events to App Configuration."
}

resource "time_sleep" "wait_for_atracker_to_appconfig_auth_policy" {
  depends_on      = [ibm_iam_authorization_policy.atracker_to_appconfig]
  create_duration = "30s"

  triggers = {
    auth_policy_id = ibm_iam_authorization_policy.atracker_to_appconfig.id
  }
}

##############################################################################
# Cloud Object Storage for Event Notifications archives
#
# When use_cdr_infrastructure is true, nothing is created here: Event
# Notifications writes into the COS bucket that CDR already created, and the
# CDR Code Engine app, COS subscription and CDR enablement already cover it.
##############################################################################

locals {
  create_cos = !var.use_cdr_infrastructure

  binaries_path = "/tmp"

  # Select the COS S3 endpoint based on the management endpoint type
  own_cos_s3_endpoint = !local.create_cos ? null : (var.management_endpoint_type_for_bucket == "private" ? module.cos[0].s3_endpoint_private : (
    var.management_endpoint_type_for_bucket == "public" ? module.cos[0].s3_endpoint_public : module.cos[0].s3_endpoint_direct
  ))

  # Effective COS target for Event Notifications: CDR's bucket or this module's own.
  cos_instance_guid = local.create_cos ? module.cos[0].cos_instance_guid : var.cdr_cos_instance_guid
  cos_bucket_name   = local.create_cos ? module.cos[0].bucket_name : var.cdr_cos_bucket_name
  cos_s3_endpoint   = local.create_cos ? local.own_cos_s3_endpoint : var.cdr_cos_s3_endpoint
}

module "cos" {
  count                               = local.create_cos ? 1 : 0
  source                              = "terraform-ibm-modules/cos/ibm"
  version                             = "11.2.5"
  create_cos_instance                 = var.existing_cos_instance_id != null ? false : true
  existing_cos_instance_id            = var.existing_cos_instance_id
  resource_group_id                   = var.resource_group_id
  cos_instance_name                   = var.cos_instance_name
  cos_plan                            = var.cos_plan
  management_endpoint_type_for_bucket = var.management_endpoint_type_for_bucket
  resource_tags                       = var.resource_tags
  add_bucket_name_suffix              = true
  create_cos_bucket                   = true
  bucket_name                         = var.cos_bucket_name
  kms_encryption_enabled              = var.kms_encryption_enabled
  kms_key_crn                         = var.kms_key_crn
  region                              = var.region
  bucket_storage_class                = var.cos_bucket_storage_class
  skip_iam_authorization_policy       = var.skip_iam_authorization_policy
}

resource "ibm_iam_authorization_policy" "en_to_cos" {
  source_service_name         = "event-notifications"
  source_resource_instance_id = local.event_notifications_guid
  target_service_name         = "cloud-object-storage"
  target_resource_instance_id = local.cos_instance_guid
  roles                       = ["Object Writer", "Reader"]
  description                 = "Allows Event Notifications to read and write notification archives to COS."
}

resource "time_sleep" "wait_for_en_to_cos_auth_policy" {
  depends_on      = [ibm_iam_authorization_policy.en_to_cos]
  create_duration = "90s"

  triggers = {
    auth_policy_id = ibm_iam_authorization_policy.en_to_cos.id
  }
}

##############################################################################
# EN topic — filters AppConfig aggregator config-change events
##############################################################################

locals {
  event_notifications_guid = module.event_notification_crn_parser.service_instance
}

module "event_notification_crn_parser" {
  source  = "terraform-ibm-modules/common-utilities/ibm//modules/crn-parser"
  version = "1.9.0"
  crn     = var.event_notifications_crn
}

resource "ibm_en_topic" "rt_cspm" {
  instance_guid = local.event_notifications_guid
  name          = var.event_notifications_topic_name
  description   = "Routes AppConfig aggregator resource config-change events to RT CSPM subscribers"

  sources {
    id = var.app_config_crn
    rules {
      enabled             = var.enable_topic_rule
      event_type_filter   = var.event_type_filter
      notification_filter = var.notification_filter
    }
  }
}

##############################################################################
# EN COS destination — notification archive
##############################################################################

resource "ibm_en_destination_cos" "cos" {
  instance_guid = local.event_notifications_guid
  name          = var.event_notifications_destination_name
  type          = "ibmcos"

  config {
    params {
      bucket_name = local.cos_bucket_name
      instance_id = local.cos_instance_guid
      endpoint    = "https://${local.cos_s3_endpoint}"
    }
  }

  depends_on = [time_sleep.wait_for_en_to_cos_auth_policy]
}

resource "ibm_en_subscription_cos" "cos" {
  instance_guid  = local.event_notifications_guid
  name           = var.event_notifications_subscription_name
  destination_id = ibm_en_destination_cos.cos.destination_id
  topic_id       = ibm_en_topic.rt_cspm.topic_id
}

##############################################################################
# Standalone mode only (use_cdr_infrastructure = false)
#
# Everything below forwards the COS bucket events to SCC Workload Protection.
# In CDR mode the CDR module already provides all of it, so none is created.
##############################################################################

##############################################################################
# Service ID and API Key for RT CSPM Application
# Skipped when CDR infrastructure is used or an existing Service ID is passed in.
##############################################################################

locals {
  create_service_id = local.create_cos && var.existing_service_id == null
}

module "rt_cspm_service_id" {
  count   = local.create_service_id ? 1 : 0
  source  = "terraform-ibm-modules/iam-service-id/ibm"
  version = "1.3.1"

  iam_service_id_name               = var.iam_service_id_name
  iam_service_id_description        = "Service ID for RT CSPM event forwarding to SCC Workload Protection"
  resource_tags                     = var.resource_tags
  iam_service_id_apikey_provision   = true
  iam_service_id_apikey_description = "API Key for RT CSPM application authentication"

  iam_service_policies = {
    (var.iam_service_policy_name) = {
      roles = ["Reader"]
      resources = [{
        service = "container-registry"
      }]
    }
  }
}

locals {
  # Resolve the effective service ID and API key. Null in CDR mode.
  effective_service_id     = local.create_cos ? (var.existing_service_id != null ? var.existing_service_id : module.rt_cspm_service_id[0].service_id) : null
  effective_service_apikey = local.create_cos ? (var.existing_service_id_apikey != null ? var.existing_service_id_apikey : module.rt_cspm_service_id[0].service_id_apikey) : null
}

##############################################################################
# RT CSPM Trusted Profile for COS Access
# Skipped when CDR infrastructure is used or an existing trusted profile ID is passed in.
##############################################################################

locals {
  create_trusted_profile = local.create_cos && var.existing_trusted_profile_id == null
}

module "rt_cspm_trusted_profile" {
  count   = local.create_trusted_profile ? 1 : 0
  source  = "terraform-ibm-modules/trusted-profile/ibm"
  version = "4.2.0"

  trusted_profile_name        = var.trusted_profile_name
  trusted_profile_description = "Trusted profile for Workload Protection interaction with Cloud Object Storage bucket"

  trusted_profile_policies = [
    # Policy for COS bucket reader
    {
      unique_identifier = "cos-bucket-reader"
      roles             = ["Content Reader", "Reader"]
      resources = [{
        service              = "cloud-object-storage"
        resource_type        = "bucket"
        resource             = local.cos_bucket_name
        resource_instance_id = local.cos_instance_guid
      }]
    },
    # Policy for accessing Service ID
    {
      unique_identifier = "service-id-viewer"
      roles             = ["Viewer"]
      resources = [{
        service       = "iam-identity"
        resource_type = "serviceid"
        resource      = local.effective_service_id
      }]
    }
  ]
  trusted_profile_identity = {
    identifier    = var.workload_protection_crn
    identity_type = "crn"
    description   = "Trust relationship for SCC Workload Protection instance"
  }
}

locals {
  # Resolve the effective trusted profile ID. Null in CDR mode.
  effective_trusted_profile_id = local.create_cos ? (var.existing_trusted_profile_id != null ? var.existing_trusted_profile_id : module.rt_cspm_trusted_profile[0].profile_id) : null
}

resource "ibm_iam_trusted_profile_identity" "service_id" {
  # Only attach the service ID identity when the trusted profile was created by this module.
  # When an existing profile is reused it already has its own identity bindings.
  count         = local.create_trusted_profile ? 1 : 0
  depends_on    = [module.rt_cspm_trusted_profile]
  profile_id    = local.effective_trusted_profile_id
  identity_type = "serviceid"
  identifier    = local.effective_service_id
  type          = "serviceid"
  description   = "Trust relationship for RT CSPM Service ID"
}


##############################################################################
# Code Engine Project and Secrets
# Skipped when CDR infrastructure is used or an existing Code Engine project ID is passed in.
##############################################################################

locals {
  create_ce_project = local.create_cos && var.existing_ce_project_id == null
}

module "code_engine_project" {
  count   = local.create_ce_project ? 1 : 0
  source  = "terraform-ibm-modules/code-engine/ibm"
  version = "4.9.19"

  project_name      = var.ce_project_name
  resource_group_id = var.resource_group_id

  # Secrets for RT CSPM application
  secrets = {
    # Generic secret for API key
    (var.ce_api_secret_name) = {
      format = "generic"
      data = {
        API_KEY = local.effective_service_apikey
      }
    }
    # Registry secret for pulling images from IBM Container Registry
    (var.ce_icr_secret_name) = {
      format = "registry"
      data = {
        username = "iamapikey"
        password = local.effective_service_apikey
        server   = "icr.io"
        email    = "noreply@cdr-app.ibm.cloud"
      }
    }
  }
}

locals {
  # Resolve the effective Code Engine project ID. Null in CDR mode.
  effective_ce_project_id = local.create_cos ? (var.existing_ce_project_id != null ? var.existing_ce_project_id : module.code_engine_project[0].project_id) : null
}

##############################################################################
# Code Engine Application
##############################################################################

module "code_engine_app" {
  count                 = local.create_cos ? 1 : 0
  source                = "terraform-ibm-modules/code-engine/ibm//modules/app"
  version               = "4.9.19"
  name                  = var.ce_app_name
  project_id            = local.effective_ce_project_id
  image_reference       = var.rt_cspm_ce_app_image
  image_secret          = var.ce_icr_secret_name
  scale_min_instances   = var.ce_app_min_scale
  scale_max_instances   = var.ce_app_max_scale
  scale_cpu_limit       = var.ce_app_cpu
  scale_memory_limit    = var.ce_app_memory
  scale_request_timeout = var.ce_app_timeout
  run_service_account   = var.ce_run_service_account
  run_env_variables = [
    {
      name  = "TARGET_ACCOUNT_ID"
      type  = "literal"
      value = var.target_account_id
    },
    {
      name  = "TRUSTED_PROFILE_ID"
      type  = "literal"
      value = local.effective_trusted_profile_id
    },
    {
      name  = "FORWARD_URL"
      type  = "literal"
      value = local.rt_cspm_ingestion_endpoint
    },
    {
      name      = "API_KEY"
      type      = "secret_key_reference"
      key       = "API_KEY"
      reference = var.ce_api_secret_name
    }
  ]
}

##############################################################################
# IAM Authorization: Code Engine to COS
##############################################################################

resource "ibm_iam_authorization_policy" "ce_to_cos" {
  count                       = local.create_cos ? 1 : 0
  source_service_name         = "codeengine"
  source_resource_instance_id = local.effective_ce_project_id
  target_service_name         = "cloud-object-storage"
  target_resource_instance_id = local.cos_instance_guid
  roles                       = ["Notifications Manager"]
}

##############################################################################
# COS Event Subscription to Code Engine
##############################################################################

resource "terraform_data" "install_required_binaries" {
  count = local.create_cos && var.install_required_binaries ? 1 : 0
  triggers_replace = {
    region            = var.region
    resource_group    = var.resource_group_id
    project_id        = local.effective_ce_project_id
    app_name          = module.code_engine_app[0].name
    bucket_name       = local.cos_bucket_name
    subscription_name = var.subscription_name
    binaries_path     = local.binaries_path
  }
  provisioner "local-exec" {
    command     = "${path.module}/../scripts/install-binaries.sh ${local.binaries_path}"
    interpreter = ["/bin/bash", "-c"]
  }
}

resource "terraform_data" "rt_cspm_cos_subscription" {
  count = local.create_cos ? 1 : 0

  # Trigger replacement when key configuration changes
  # Store values in triggers_replace so they can be referenced in destroy provisioner via self
  triggers_replace = {
    ibmcloud_api_key  = sensitive(var.ibmcloud_api_key)
    region            = var.region
    resource_group    = var.resource_group_id
    project_id        = local.effective_ce_project_id
    app_name          = module.code_engine_app[0].name
    bucket_name       = local.cos_bucket_name
    subscription_name = var.subscription_name
    binaries_path     = local.binaries_path
  }

  provisioner "local-exec" {
    command     = "${path.module}/scripts/create-cos-subscription.sh ${local.binaries_path}"
    interpreter = ["/bin/bash", "-c"]
    environment = {
      IBMCLOUD_API_KEY  = self.triggers_replace.ibmcloud_api_key
      REGION            = self.triggers_replace.region
      RESOURCE_GROUP    = self.triggers_replace.resource_group
      PROJECT_ID        = self.triggers_replace.project_id
      APP_NAME          = self.triggers_replace.app_name
      BUCKET_NAME       = self.triggers_replace.bucket_name
      SUBSCRIPTION_NAME = self.triggers_replace.subscription_name
    }
  }

  provisioner "local-exec" {
    when        = destroy
    command     = "${path.module}/scripts/delete-cos-subscription.sh ${self.triggers_replace.binaries_path}"
    interpreter = ["/bin/bash", "-c"]
    environment = {
      IBMCLOUD_API_KEY  = self.triggers_replace.ibmcloud_api_key
      REGION            = self.triggers_replace.region
      RESOURCE_GROUP    = self.triggers_replace.resource_group
      PROJECT_ID        = self.triggers_replace.project_id
      SUBSCRIPTION_NAME = self.triggers_replace.subscription_name
    }
  }

  depends_on = [
    ibm_iam_authorization_policy.ce_to_cos,
    module.code_engine_app
  ]
}

################################################################
# Enable CDR for SCC Workload Protection instance
# Skipped in CDR mode: the CDR module already enables it.
################################################################

# CDR can only be enabled after the infrastructure exists
# Similar to CSPM, we use REST API to configure CDR
resource "restapi_object" "cdr" {
  count = local.create_cos ? 1 : 0
  path  = "/v2/resource_instances/${var.workload_protection_guid}"

  data = jsonencode({
    parameters = {
      enable_cdr = true
      target_cdr_accounts = [
        {
          cdr_bucket_region      = var.region
          cdr_bucket_name        = local.cos_bucket_name
          cdr_trusted_profile_id = local.effective_trusted_profile_id
          cdr_service_id         = local.effective_service_id
          cdr_ingestion_url      = local.rt_cspm_ingestion_endpoint
          account_id             = var.target_account_id
        }
      ]
    }
  })
  create_method  = "PATCH"
  update_method  = "PATCH"
  destroy_method = "PATCH"
  read_method    = "GET"
  read_path      = "/v2/resource_instances/${var.workload_protection_guid}"

  # Workaround for https://github.com/Mastercard/terraform-provider-restapi/issues/319
  # The API returns many server-generated fields that cause drift detection.
  # ignore_all_server_changes prevents the provider from detecting drift on
  # fields returned by the API that weren't in our original request.
  ignore_all_server_changes = true

  depends_on = [terraform_data.rt_cspm_cos_subscription]
}

################################################################
# Enable real-time config collection on the App Configuration aggregator
################################################################

resource "time_sleep" "wait_for_atracker_target_propagation" {
  depends_on      = [ibm_atracker_target.appconfig, ibm_atracker_route.rt_cspm]
  create_duration = "60s"

  triggers = {
    target_id = ibm_atracker_target.appconfig.id
    route_id  = ibm_atracker_route.rt_cspm.id
  }
}

data "ibm_config_aggregator_settings" "config_aggregator_settings" {
  instance_id = local.app_config_guid
  region      = var.region
}

resource "ibm_config_aggregator_settings" "config_aggregator_settings_instance" {
  instance_id                 = local.app_config_guid
  region                      = data.ibm_config_aggregator_settings.config_aggregator_settings.region
  resource_collection_regions = data.ibm_config_aggregator_settings.config_aggregator_settings.regions
  resource_collection_enabled = true
  realtime_config_enabled     = true
  trusted_profile_id          = data.ibm_config_aggregator_settings.config_aggregator_settings.trusted_profile_id

  depends_on = [
    time_sleep.wait_for_atracker_target_propagation,
    ibm_iam_authorization_policy.atracker_to_appconfig,
    restapi_object.cdr
  ]
}
