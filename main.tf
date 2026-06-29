##############################################################################
# terraform-ibm-scc-workload-protection
#
# Creates Security and Compliance Center Workload Protection
##############################################################################

##############################################################################
# SCC WP
##############################################################################

locals {
  target_account_id = ibm_resource_instance.scc_wp.account_id
}

resource "ibm_resource_instance" "scc_wp" {
  name              = var.name
  resource_group_id = var.resource_group_id
  service           = "sysdig-secure"
  plan              = var.scc_wp_service_plan
  location          = var.region
  tags              = var.resource_tags
  parameters = {
    cloud_monitoring_connected_instance = var.cloud_monitoring_instance_crn
  }
  # lifecycle ignores cloud_monitoring_conmected_instance as it can't change after scc-workload-protection instance connects.
  lifecycle {
    ignore_changes = [
      parameters["cloud_monitoring_connected_instance"]
    ]
  }
}

##############################################################################
# Check Account Type
##############################################################################

data "ibm_iam_auth_token" "token" {
  depends_on = [ibm_resource_instance.scc_wp]
  count      = var.cspm_enabled ? 1 : 0
}

module "account_type_check" {
  count             = var.cspm_enabled ? 1 : 0
  source            = "./modules/account_check"
  target_account_id = local.target_account_id
  iam_token         = data.ibm_iam_auth_token.token[0].iam_access_token
}

##############################################################################
# SCC WP Instance Key
##############################################################################

resource "ibm_resource_key" "scc_wp_resource_key" {
  name                 = var.resource_key_name
  resource_instance_id = ibm_resource_instance.scc_wp.id
  role                 = "Manager"
  tags                 = var.resource_key_tags
}

##############################################################################
# Attach Access Tags
##############################################################################

# Check whether access tags are valid and exist in the account
data "ibm_iam_access_tag" "access_tags" {
  for_each = toset(var.access_tags)
  name     = each.value
}

resource "ibm_resource_tag" "scc_wp_access_tag" {
  depends_on  = [data.ibm_iam_access_tag.access_tags] # Force dependency on data source validation to ensure access_tags exist and are valid before use.
  count       = length(var.access_tags) == 0 ? 0 : 1
  resource_id = ibm_resource_instance.scc_wp.id
  tags        = var.access_tags
  tag_type    = "access"
}

##############################################################################
# Context Based Restrictions
##############################################################################
module "cbr_rule" {
  count            = length(var.cbr_rules) > 0 ? length(var.cbr_rules) : 0
  source           = "terraform-ibm-modules/cbr/ibm//modules/cbr-rule-module"
  version          = "1.36.6"
  rule_description = var.cbr_rules[count.index].description
  enforcement_mode = var.cbr_rules[count.index].enforcement_mode
  rule_contexts    = var.cbr_rules[count.index].rule_contexts
  resources = [{
    attributes = [
      {
        name     = "accountId"
        value    = var.cbr_rules[count.index].account_id
        operator = "stringEquals"
      },
      {
        name     = "serviceInstance"
        value    = ibm_resource_instance.scc_wp.guid
        operator = "stringEquals"
      },
      {
        name     = "serviceName"
        value    = "sysdig-secure"
        operator = "stringEquals"
      }
    ],
    tags = var.cbr_rules[count.index].tags
  }]
}

########################################################################################################################
# SCC Workload Protection Trusted Profile
########################################################################################################################

# Create Trusted profile for SCC Workload Protection instance
module "trusted_profile_scc_wp" {
  count                       = var.cspm_enabled ? 1 : 0
  source                      = "terraform-ibm-modules/trusted-profile/ibm"
  version                     = "4.2.0"
  trusted_profile_name        = var.scc_workload_protection_trusted_profile_name
  trusted_profile_description = "Trusted Profile for SCC workload Protection instance ${ibm_resource_instance.scc_wp.guid} with required access for configuration aggregator."

  trusted_profile_identity = {
    identifier    = ibm_resource_instance.scc_wp.crn
    identity_type = "crn"
  }

  trusted_profile_policies = [
    {
      unique_identifier = "scc-wp"
      roles             = ["Service Configuration Reader", "Viewer", "Configuration Aggregator Reader"]
      resources = [{
        service = "apprapp"
      }]
      description = "App Config access"
    },
    {
      unique_identifier = "scc-wp-enterprise"
      roles             = ["Viewer", "Usage Report Viewer"]
      resources = [{
        service = "enterprise"
      }]
      description = "Enterprise access"
    }
  ]

  trusted_profile_links = [{
    unique_identifier = "scc-wp-vsi-link"
    cr_type           = "VSI"
    links = [{
      crn = ibm_resource_instance.scc_wp.crn
    }]
  }]
}

################################################################
# Enable CSPM for SCC Workload Protection instance
################################################################

# CSPM can only be enabled after the trusted profile exists,
# but profile can only exist after instance has been created
# hence we cannot directly enable CSPM in the instance creation
# and need to use a separate resource to enable it
resource "restapi_object" "cspm" {
  path = "//${var.resource_controller_endpoint}/v2/resource_instances/${ibm_resource_instance.scc_wp.guid}"

  data = jsonencode({
    parameters = {
      enable_cspm = var.cspm_enabled
      target_accounts = var.cspm_enabled ? [
        {
          account_id         = ibm_resource_instance.scc_wp.account_id
          account_type       = module.account_type_check[0].account_type
          config_crn         = var.app_config_crn
          trusted_profile_id = module.trusted_profile_scc_wp[0].profile_id
        }
      ] : []
    }
  })
  create_method  = "PATCH"
  update_method  = "PATCH"
  destroy_method = "PATCH"
  read_method    = "GET"
  read_path      = "//${var.resource_controller_endpoint}/v2/resource_instances/${ibm_resource_instance.scc_wp.guid}"

  # Workaround for https://github.com/Mastercard/terraform-provider-restapi/issues/319
  # The API returns many server-generated fields that cause drift detection.
  # ignore_all_server_changes prevents the provider from detecting drift on
  # fields returned by the API that weren't in our original request.
  ignore_all_server_changes = true
}

################################################################
# CDR (Cloud Detection and Response)
################################################################

# # Get Sysdig environment URL from the resource key endpoint
locals {
  # Extract the Sysdig environment URL from the endpoint
  # Example: "https://us-south.monitoring.cloud.ibm.com" -> "us-south.monitoring.cloud.ibm.com"
  sysdig_endpoint = var.cdr_enabled ? trimprefix(ibm_resource_key.scc_wp_resource_key.credentials["Sysdig Endpoint"], "https://") : ""
}

# Create CDR infrastructure if enabled
module "cdr" {
  count  = var.cdr_enabled ? 1 : 0
  source = "./modules/cdr"

  # IBM Cloud Authentication
  ibmcloud_api_key = var.ibmcloud_api_key

  region            = var.region
  resource_group_id = var.resource_group_id
  resource_tags     = var.resource_tags

  # IAM Service ID
  iam_service_id_name     = var.cdr_iam_service_id_name
  iam_service_policy_name = var.cdr_iam_service_policy_name


  # COS
  cos_instance_name             = var.cdr_cos_instance_name
  cos_bucket_name               = var.cdr_cos_bucket_name
  cos_bucket_storage_class      = var.cdr_cos_bucket_storage_class
  cos_plan                      = var.cdr_cos_plan
  kms_encryption_enabled        = var.cdr_kms_encryption_enabled
  kms_key_crn                   = var.cdr_kms_key_crn
  skip_iam_authorization_policy = var.cdr_skip_iam_authorization_policy

  # Activity Tracker
  atracker_target_name = var.cdr_atracker_target_name
  atracker_route_name  = var.cdr_atracker_route_name
  atracker_locations   = var.cdr_atracker_locations

  # Trusted Profile
  trusted_profile_name = var.cdr_trusted_profile_name

  # SCC Workload Protection
  target_account_id        = local.target_account_id
  sysdig_environment_url   = local.sysdig_endpoint
  workload_protection_crn  = ibm_resource_instance.scc_wp.crn
  workload_protection_guid = ibm_resource_instance.scc_wp.guid

  # Code Engine
  ce_project_name        = var.cdr_ce_project_name
  ce_app_name            = var.cdr_ce_app_name
  cdr_ce_app_image       = var.cdr_ce_app_image
  ce_app_min_scale       = var.cdr_ce_app_min_scale
  ce_app_max_scale       = var.cdr_ce_app_max_scale
  ce_app_cpu             = var.cdr_ce_app_cpu
  ce_app_memory          = var.cdr_ce_app_memory
  ce_app_timeout         = var.cdr_ce_app_timeout
  ce_run_service_account = var.cdr_ce_run_service_account
  ce_api_secret_name     = var.cdr_ce_api_secret_name
  ce_icr_secret_name     = var.cdr_ce_icr_secret_name

  # COS Subscription
  subscription_name         = var.cdr_subscription_name
  install_required_binaries = var.cdr_install_required_binaries

  # Enable CDR
  resource_controller_endpoint = var.resource_controller_endpoint

  depends_on = [
    ibm_resource_instance.scc_wp,
    ibm_resource_key.scc_wp_resource_key,
    restapi_object.cspm
  ]
}
