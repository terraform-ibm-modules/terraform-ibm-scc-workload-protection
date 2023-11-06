##############################################################################
# terraform-ibm-scc-workload-protection
#
# Creates Security and Compliance Center Workload Protection
##############################################################################

##############################################################################
# SCC WP
##############################################################################

resource "ibm_resource_instance" "scc_wp" {
  name              = "${var.name}-scc-wp"
  resource_group_id = var.resource_group_id
  service           = "sysdig-secure"
  plan              = var.scc_wp_service_plan
  location          = var.region
  tags              = var.scc_wp_tags
}

##############################################################################
# SCC WP Instance Key
##############################################################################

resource "ibm_resource_key" "scc_wp_keys" {
  for_each             = var.scc_wp_keys
  name                 = each.key
  role                 = each.value
  resource_instance_id = ibm_resource_instance.scc_wp.id
}
