##############################################################################
# CDR Module - Cloud Detection and Response
# Creates infrastructure for forwarding Activity Tracker events to SCC-WP:
# - COS bucket for Activity Tracker events
# - Activity Tracker target and route
# - Service ID and API key for authentication
# - Code Engine project and app for event forwarding
# - Event subscription connecting COS to Code Engine
##############################################################################

locals {
  # Build the Sysdig ingestion URL from environment URL and service ID
  ingestion_url    = "https://${var.sysdig_environment_url}/api/cloudingestion/webhooks/ibm/v1/${module.cdr_service_id.service_id}"
  binaries_path    = "/tmp"
  cdr_ce_app_image = "icr.io/ext/sysdig/cdr-notification-app:latest"
}

##############################################################################
# Cloud Object Storage for Activity Tracker Events
##############################################################################

module "cos" {
  source            = "terraform-ibm-modules/cos/ibm"
  version           = "10.16.5"
  resource_group_id = var.resource_group_id
  cos_instance_name = var.cos_instance_name
  cos_plan          = var.cos_plan
  resource_tags     = var.resource_tags
  create_cos_bucket = false
}

module "cos_bucket" {
  source  = "terraform-ibm-modules/cos/ibm//modules/buckets"
  version = "10.16.5"
  bucket_configs = [
    {
      bucket_name                   = var.cos_bucket_name
      kms_encryption_enabled        = var.kms_encryption_enabled
      kms_key_crn                   = var.kms_key_crn
      region_location               = var.region
      resource_instance_id          = module.cos.cos_instance_id
      storage_class                 = var.cos_bucket_storage_class
      skip_iam_authorization_policy = var.skip_iam_authorization_policy
    }
  ]
}

##############################################################################
# Activity Tracker Target and Route
##############################################################################

module "activity_tracker" {
  source  = "terraform-ibm-modules/activity-tracker/ibm"
  version = "1.8.8"

  cos_targets = [
    {
      endpoint                          = module.cos_bucket.buckets[var.cos_bucket_name].s3_endpoint_direct
      bucket_name                       = module.cos_bucket.buckets[var.cos_bucket_name].bucket_name
      instance_id                       = module.cos.cos_instance_crn
      service_to_service_enabled        = true
      target_region                     = var.region
      target_name                       = var.atracker_target_name
      skip_atracker_cos_iam_auth_policy = false
    }
  ]

  activity_tracker_routes = [
    {
      locations  = var.atracker_locations
      target_ids = [module.activity_tracker.activity_tracker_targets[var.atracker_target_name].id]
      route_name = var.atracker_route_name
    }
  ]
}

##############################################################################
# Service ID and API Key for CDR Application
##############################################################################

module "cdr_service_id" {
  source  = "terraform-ibm-modules/iam-service-id/ibm"
  version = "1.3.0"

  iam_service_id_name               = var.iam_service_id_name
  iam_service_id_description        = "Service ID for CDR event forwarding to SCC Workload Protection"
  iam_service_id_tags               = var.resource_tags
  iam_service_id_apikey_provision   = true
  iam_service_id_apikey_description = "API Key for CDR application authentication"

  iam_service_policies = {
    (var.iam_service_policy_name) = {
      roles = ["Reader"]
      resources = [{
        service = "container-registry"
      }]
    }
  }
}
##############################################################################
# CDR Trusted Profile for COS Access
##############################################################################

module "cdr_trusted_profile" {
  source  = "terraform-ibm-modules/trusted-profile/ibm"
  version = "4.1.0"

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
        resource             = module.cos_bucket.buckets[var.cos_bucket_name].bucket_name
        resource_instance_id = module.cos.cos_instance_guid
      }]
    },
    # Policy for accessing Service ID
    {
      unique_identifier = "service-id-viewer"
      roles             = ["Viewer"]
      resources = [{
        service       = "iam-identity"
        resource_type = "serviceid"
        resource      = module.cdr_service_id.service_id
      }]
    }
  ]
  trusted_profile_identity = {
    identifier    = var.workload_protection_crn
    identity_type = "crn"
    description   = "Trust relationship for SCC Workload Protection instance"
  }
}

resource "ibm_iam_trusted_profile_identity" "service_id" {
  profile_id    = module.cdr_trusted_profile.profile_id
  identity_type = "serviceid"
  identifier    = module.cdr_service_id.service_id
  type          = "serviceid"
  description   = "Trust relationship for CDR Service ID"
}


##############################################################################
# Code Engine Project and Secrets
##############################################################################

module "code_engine_project" {
  source  = "terraform-ibm-modules/code-engine/ibm"
  version = "4.9.6"

  project_name      = var.ce_project_name
  resource_group_id = var.resource_group_id

  # Secrets for CDR application
  secrets = {
    # Generic secret for API key
    (var.ce_api_secret_name) = {
      format = "generic"
      data = {
        API_KEY = module.cdr_service_id.service_id_apikey
      }
    }
    # Registry secret for pulling images from IBM Container Registry
    (var.ce_icr_secret_name) = {
      format = "registry"
      data = {
        username = "iamapikey"
        password = module.cdr_service_id.service_id_apikey
        server   = "icr.io"
        email    = "noreply@cdr-app.ibm.cloud"
      }
    }
  }
}

##############################################################################
# Code Engine Application
##############################################################################

module "code_engine_app" {
  source                = "terraform-ibm-modules/code-engine/ibm//modules/app"
  version               = "4.9.6"
  name                  = var.ce_app_name
  project_id            = module.code_engine_project.project_id
  image_reference       = local.cdr_ce_app_image
  image_secret          = var.ce_icr_secret_name
  scale_min_instances   = var.ce_app_min_scale
  scale_max_instances   = var.ce_app_max_scale
  scale_cpu_limit       = var.ce_app_cpu_limit
  scale_memory_limit    = var.ce_app_memory_limit
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
      value = module.cdr_trusted_profile.profile_id
    },
    {
      name  = "FORWARD_URL"
      type  = "literal"
      value = local.ingestion_url
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
  source_service_name         = "codeengine"
  source_resource_instance_id = module.code_engine_project.project_id
  target_service_name         = "cloud-object-storage"
  target_resource_instance_id = module.cos.cos_instance_guid
  roles                       = ["Notifications Manager"]
}

##############################################################################
# COS Event Subscription to Code Engine
##############################################################################

resource "terraform_data" "install_required_binaries" {
  count = var.install_required_binaries ? 1 : 0
  triggers_replace = {
    script_hash = filesha256("${path.module}/../scripts/install-binaries.sh")
  }
  provisioner "local-exec" {
    command     = "${path.module}/../scripts/install-binaries.sh ${local.binaries_path}"
    interpreter = ["/bin/bash", "-c"]
  }
}

resource "terraform_data" "cdr_cos_subscription" {
  # Trigger replacement when key configuration changes
  # Store values in triggers_replace so they can be referenced in destroy provisioner via self
  triggers_replace = {
    ibmcloud_api_key  = var.ibmcloud_api_key
    region            = var.region
    resource_group    = var.resource_group_id
    project_id        = module.code_engine_project.project_id
    app_name          = module.code_engine_app.name
    bucket_name       = module.cos_bucket.buckets[var.cos_bucket_name].bucket_name
    subscription_name = var.subscription_name
    binaries_path     = local.binaries_path
  }

  provisioner "local-exec" {
    command     = "${path.module}/../scripts/create-cos-subscription.sh ${local.binaries_path}"
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
    command     = "${path.module}/../scripts/delete-cos-subscription.sh ${self.triggers_replace.binaries_path}"
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
    module.code_engine_project,
    module.code_engine_app
  ]
}


################################################################
# Enable CDR for SCC Workload Protection instance
################################################################

# CDR can only be enabled after the infrastructure exists
# Similar to CSPM, we use REST API to configure CDR
resource "restapi_object" "cdr" {
  path = "/v2/resource_instances/${var.workload_protection_guid}"

  data = jsonencode({
    parameters = {
      enable_cdr = true
      target_cdr_accounts = [
        {
          cdr_bucket_region      = var.region
          cdr_bucket_name        = module.cos_bucket.buckets[var.cos_bucket_name].bucket_name
          cdr_trusted_profile_id = module.cdr_trusted_profile.profile_id
          cdr_service_id         = module.cdr_service_id.service_id
          cdr_ingestion_url      = local.ingestion_url
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

  depends_on = [terraform_data.cdr_cos_subscription]
}
