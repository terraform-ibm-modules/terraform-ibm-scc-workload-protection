########################################################################################################################
# Resource group
########################################################################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.1.6"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

########################################################################################################################
# IBM Cloud monitoring instance
########################################################################################################################

module "cloud_monitoring" {
  source            = "terraform-ibm-modules/observability-instances/ibm//modules/cloud_monitoring"
  version           = "3.4.2"
  resource_group_id = module.resource_group.resource_group_id
  region            = var.region
  instance_name     = "${var.prefix}-cm"
}

##############################################################################
# Get Cloud Account ID
##############################################################################

data "ibm_iam_account_settings" "iam_account_settings" {
}

##############################################################################
# VPC
##############################################################################
resource "ibm_is_vpc" "example_vpc" {
  name           = "${var.prefix}-vpc"
  resource_group = module.resource_group.resource_group_id
  tags           = var.resource_tags
}

##############################################################################
# Create CBR Zone
##############################################################################
module "cbr_zone" {
  source           = "terraform-ibm-modules/cbr/ibm//modules/cbr-zone-module"
  version          = "1.29.0"
  name             = "${var.prefix}-VPC-network-zone"
  zone_description = "CBR Network zone representing VPC"
  account_id       = data.ibm_iam_account_settings.iam_account_settings.account_id
  addresses = [{
    type  = "vpc", # to bind a specific vpc to the zone
    value = ibm_is_vpc.example_vpc.crn,
  }]
}

########################################################################################################################
# SCC WP instance
########################################################################################################################

module "scc_wp" {
  source                        = "../.."
  name                          = var.prefix
  region                        = var.region
  resource_group_id             = module.resource_group.resource_group_id
  resource_tags                 = var.resource_tags
  access_tags                   = var.access_tags
  cloud_monitoring_instance_crn = module.cloud_monitoring.crn

  cbr_rules = [
    {
      description      = "${var.prefix}-SCC-WP access only from vpc"
      enforcement_mode = "enabled"
      account_id       = data.ibm_iam_account_settings.iam_account_settings.account_id
      tags = [
        {
          name  = "test-name"
          value = "test-value"
        }
      ]
      rule_contexts = [{
        attributes = [
          {
            "name" : "endpointType",
            "value" : "private"
          },
          {
            name  = "networkZoneId"
            value = module.cbr_zone.zone_id
        }]
      }]
    }
  ]
}
