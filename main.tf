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
  version          = "1.28.1"
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
        value    = "Security and Compliance Center Workload Protection"
        operator = "stringEquals"
      }
    ],
    tags = var.cbr_rules[count.index].tags
  }]
}
