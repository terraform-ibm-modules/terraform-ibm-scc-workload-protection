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

module "trusted_profile_app_config_general" {
  source                         = "../../../terraform-ibm-trusted-profile"
  trusted_profile_name           = "app-config-general-profile"
  trusted_profile_description    = "Trusted Profile for App Config general permissions"
  create_trusted_relationship    = true

  trusted_profile_identity = {
    identifier    = module.app_config.app_config_crn
    identity_type = "crn"
    type          = "crn"
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
resource "ibm_iam_custom_role" "template_assignment_reader" {
  name         = "TemplateAssignmentReader"
  service      = "iam-identity"
  display_name = "Template Assignment Reader"
  description  = "Custom role to allow reading template assignments"
  actions      = ["iam-identity.profile-assignment.read"]
}

# Trusted Profile for App Config enterprise-level permissions
module "trusted_profile_app_config_enterprise" {
  source                         = "../../../terraform-ibm-trusted-profile"
  trusted_profile_name           = "app-config-enterprise-profile"
  trusted_profile_description    = "Trusted Profile for App Config to manage IAM templates"
  create_trusted_relationship    = true

  trusted_profile_identity = {
    identifier    = module.app_config.app_config_crn
    identity_type = "crn"
    type          = "crn"
  }

  trusted_profile_policies = [
    {
      roles = ["Viewer", "Template Assignment Reader"]
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

module "trusted_profile_scc_wp" {
  source                         = "../../../terraform-ibm-trusted-profile"
  trusted_profile_name           = "scc-wp-profile"
  trusted_profile_description    = "Trusted Profile for SCC-WP to access App Config and enterprise"
  create_trusted_relationship    = true

  trusted_profile_identity = {
    identifier    = module.scc_wp.crn
    identity_type = "crn"
    type          = "crn"
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

module "trusted_profile_template" {
  source              = "../../../terraform-ibm-trusted-profile/modules/trusted-profile-template"
  profile_name        = "Trusted Profile for IBM Cloud CSPM in SCC-WP"
  profile_description = "Template profile used to onboard child accounts"
  identity_crn        = module.app_config.app_config_crn
  onboard_account_groups = true

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

