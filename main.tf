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
