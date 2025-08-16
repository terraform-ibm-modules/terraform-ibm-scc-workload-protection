##############################################################################
# terraform-ibm-scc-workload-protection
#
# Creates Security and Compliance Center Workload Protection
##############################################################################

##############################################################################
# SCC WP
##############################################################################

resource "ibm_resource_instance" "scc_wp" {
  name              = var.name
  resource_group_id = var.resource_group_id
  service           = "sysdig-secure"
  plan              = var.scc_wp_service_plan
  location          = var.region
  tags              = var.resource_tags
  parameters = {
    cloud_monitoring_connected_instance : var.cloud_monitoring_instance_crn
  }
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

resource "ibm_resource_tag" "scc_wp_access_tag" {
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
  version          = "1.33.0"
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
  version                     = "3.1.1"
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
  path = "/v2/resource_instances/${ibm_resource_instance.scc_wp.guid}"

  data = jsonencode({
    parameters = {
      enable_cspm = var.cspm_enabled
      target_accounts = var.cspm_enabled ? [
        {
          account_id         = ibm_resource_instance.scc_wp.account_id
          config_crn         = var.app_config_crn
          trusted_profile_id = module.trusted_profile_scc_wp[0].profile_id
        }
      ] : []
    }
  })
  create_method  = "PATCH" # Specify the HTTP method for updates
  update_method  = "PATCH"
  destroy_method = "PATCH"
  force_new      = [var.cspm_enabled]
}
