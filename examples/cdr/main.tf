##############################################################################
# SCC Workload Protection with CDR Test Example
#
# This is a test example for incremental CDR module testing.
# You can comment/uncomment sections as needed for testing.
##############################################################################

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
# Create Key Protect resources
##############################################################################

locals {
  key_ring_name   = "${var.prefix}-cos-key-ring"
  bucket_key_name = "${var.prefix}-bucket-key"
  vault_key_name  = "${var.prefix}-vault-key"
  bucket_name     = "${var.prefix}-cdr-events"
}

module "key_protect_all_inclusive" {
  source                    = "terraform-ibm-modules/kms-all-inclusive/ibm"
  version                   = "5.6.5"
  key_protect_instance_name = "${var.prefix}-kp"
  resource_group_id         = module.resource_group.resource_group_id
  enable_metrics            = false
  region                    = var.region
  keys = [
    {
      key_ring_name = (local.key_ring_name)
      keys = [
        {
          key_name     = (local.bucket_key_name)
          force_delete = true
        },
        {
          key_name     = (local.vault_key_name)
          force_delete = true
        }
      ]
    }
  ]
  resource_tags = var.resource_tags
}

##############################################################################
# App Config Instance (Required for CSPM)
##############################################################################

module "app_config" {
  source                                 = "terraform-ibm-modules/app-configuration/ibm"
  version                                = "1.18.6"
  region                                 = var.region
  resource_group_id                      = module.resource_group.resource_group_id
  app_config_plan                        = "basic"
  app_config_name                        = "${var.prefix}-app-config"
  resource_tags                          = var.resource_tags
  enable_config_aggregator               = true
  config_aggregator_trusted_profile_name = "${var.prefix}-app-config-tp"
}

##############################################################################
# SCC Workload Protection with CDR
##############################################################################

module "scc_wp_cdr" {
  source            = "../../"
  name              = "${var.prefix}-scc-wp"
  region            = var.region
  resource_group_id = module.resource_group.resource_group_id
  resource_tags     = var.resource_tags

  # CSPM Configuration
  cspm_enabled                              = true
  app_config_crn                            = module.app_config.app_config_crn
  scc_workload_protection_trusted_profile_name = "${var.prefix}-wp-trusted-profile"

  # CDR Configuration
  cdr_enabled            = true
  ibmcloud_api_key       = var.ibmcloud_api_key
  cdr_cos_instance_name  = "${var.prefix}-cdr-cos-instance"
  cdr_cos_bucket_name    = local.bucket_name
  cdr_cos_bucket_storage_class  = "smart"
  cdr_trusted_profile_name = "${var.prefix}-cdr-trusted-profile"
  cdr_iam_service_id_name = "${var.prefix}-cdr-service-id"
  cdr_ce_project_name = "${var.prefix}-cdr-ce-project"
  cdr_atracker_locations = ["global"]
  cdr_atracker_target_name = var.cdr_atracker_target_name
  cdr_atracker_route_name  = var.cdr_atracker_route_name
  cdr_kms_encryption_enabled        = true
  cdr_kms_key_crn                   = module.key_protect_all_inclusive.keys["${local.key_ring_name}.${local.bucket_key_name}"].crn
  cdr_skip_iam_authorization_policy = false
}
