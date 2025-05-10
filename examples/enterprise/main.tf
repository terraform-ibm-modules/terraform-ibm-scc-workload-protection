########################################################################################################################
# Resource group
########################################################################################################################

module "resource_group" {
  source                       = "terraform-ibm-modules/resource-group/ibm"
  version                      = "1.2.0"
  resource_group_name          = var.resource_group == null ? "${var.prefix}-rg" : null
  existing_resource_group_name = var.resource_group
}

########################################################################################################################
# SCC Workload Protection
########################################################################################################################

# Create SCC Workload Protection instance
module "scc_wp" {
  source              = "../.."
  name                = var.prefix
  region              = var.region
  resource_group_id   = module.resource_group.resource_group_id
  resource_tags       = var.resource_tags
  access_tags         = var.access_tags
  scc_wp_service_plan = "graduated-tier"
}

# Create Trusted profile for SCC Workload Protection instance
module "trusted_profile_scc_wp" {
  source                      = "terraform-ibm-modules/trusted-profile/ibm"
  version                     = "2.3.0"
  trusted_profile_name        = "${var.prefix}-scc-wp-profile"
  trusted_profile_description = "Trusted Profile for SCC-WP to access App Config and enterprise"

  trusted_profile_identity = {
    identifier    = module.scc_wp.crn
    identity_type = "crn"
  }

  trusted_profile_policies = [
    {
      roles = ["Viewer", "Service Configuration Reader", "Manager"]
      resources = [{
        service = "apprapp"
      }]
      description = "App Config access"
    },
    {
      roles = ["Viewer", "Usage Report Viewer"]
      resources = [{
        service = "enterprise"
      }]
      description = "Enterprise access"
    }
  ]

  trusted_profile_links = [{
    cr_type = "VSI"
    links = [{
      crn = module.scc_wp.crn
    }]
  }]
}

########################################################################################################################
# App Config
########################################################################################################################

# Create new App Config instance
module "app_config" {
  source            = "terraform-ibm-modules/app-configuration/ibm"
  version           = "1.5.0"
  region            = var.region
  resource_group_id = module.resource_group.resource_group_id
  app_config_name   = "${var.prefix}-app-config"
  app_config_tags   = var.resource_tags
}

# Create trusted profile for App Config instance
module "trusted_profile_app_config_general" {
  source                      = "terraform-ibm-modules/trusted-profile/ibm"
  version                     = "2.3.0"
  trusted_profile_name        = "${var.prefix}-app-config-general-profile"
  trusted_profile_description = "Trusted Profile for App Config general permissions"

  trusted_profile_identity = {
    identifier    = module.app_config.app_config_crn
    identity_type = "crn"
  }

  trusted_profile_policies = [
    {
      roles              = ["Viewer", "Service Configuration Reader"]
      account_management = true
      description        = "All Account Management Services"
    },
    {
      roles = ["Viewer", "Service Configuration Reader", "Reader"]
      resource_attributes = [{
        name     = "serviceType"
        value    = "service"
        operator = "stringEquals"
      }]
      description = "All Identity and Access enabled services"
    }
  ]

  trusted_profile_links = [{
    cr_type = "VSI"
    links = [{
      crn = module.app_config.app_config_crn
    }]
  }]
}

# Creates the custom role inline
# This role, "Template Assignment Reader", is used in the trusted profile
# to grant permission to read IAM template assignments. It is required
# by the App Config enterprise-level trusted profile to manage IAM templates.
locals {
  custom_role = "Template Assignment Reader"
}
resource "ibm_iam_custom_role" "template_assignment_reader" {
  name         = "TemplateAssignmentReader"
  service      = "iam-identity"
  display_name = local.custom_role
  description  = "Custom role to allow reading template assignments"
  actions      = ["iam-identity.profile-assignment.read"]
}

# Trusted Profile for App Config enterprise-level permissions
module "trusted_profile_app_config_enterprise" {
  source                      = "terraform-ibm-modules/trusted-profile/ibm"
  version                     = "2.3.0"
  trusted_profile_name        = "${var.prefix}-app-config-enterprise-profile"
  trusted_profile_description = "Trusted Profile for App Config to manage IAM templates"

  trusted_profile_identity = {
    identifier    = module.app_config.app_config_crn
    identity_type = "crn"
  }

  trusted_profile_policies = [
    {
      roles = ["Viewer", local.custom_role]
      resource_attributes = [{
        name     = "service_group_id"
        value    = "IAM"
        operator = "stringEquals"
      }]
      description = "IAM access with custom role"
    },
    {
      roles = ["Viewer"]
      resources = [{
        service = "enterprise"
      }]
      description = "Enterprise access"
    }
  ]

  trusted_profile_links = [{
    cr_type = "VSI"
    links = [{
      crn = module.app_config.app_config_crn
    }]
  }]
}

########################################################################################################################
# Trusted profile template
########################################################################################################################

module "trusted_profile_template" {
  source                     = "terraform-ibm-modules/trusted-profile/ibm//modules/trusted-profile-template"
  version                    = "2.3.0"
  template_name              = "Trusted Profile Template for SCC-WP-${var.prefix}"
  template_description       = "IAM trusted profile template to onboard accounts for CSPM"
  profile_name               = "Trusted Profile for IBM Cloud CSPM in SCC-WP-${var.prefix}"
  profile_description        = "Template profile used to onboard child accounts"
  identity_crn               = module.app_config.app_config_crn
  onboard_all_account_groups = true

  policy_templates = [
    {
      name        = "identity-access"
      description = "Policy template for identity services"
      roles       = ["Viewer", "Reader"]
      service     = "service"
    },
    {
      name        = "platform-access"
      description = "Policy template for platform services"
      roles       = ["Viewer", "Service Configuration Reader"]
      service     = "platform_service"
    }
  ]
}

########################################################################################################################
# Enable the config aggregator
########################################################################################################################

resource "ibm_config_aggregator_settings" "scc_wp_aggregator" {
  instance_id                 = module.app_config.app_config_guid
  region                      = var.region
  resource_collection_enabled = true
  resource_collection_regions = ["all"]
  trusted_profile_id          = module.trusted_profile_app_config_general.profile_id

  additional_scope {
    type          = "Enterprise"
    enterprise_id = var.enterprise_id

    profile_template {
      id                 = module.trusted_profile_template.trusted_profile_template_id
      trusted_profile_id = module.trusted_profile_app_config_enterprise.profile_id
    }
  }
}
