########################################################################################################################
# Outputs
########################################################################################################################

output "name" {
  description = "Name of created SCC WP instance."
  value       = ibm_resource_instance.scc_wp.name
}

output "id" {
  description = "ID of created SCC WP instance."
  value       = ibm_resource_instance.scc_wp.crn
}

output "sysdig_collector_endpoint" {
  description = "Sysdig collector endpoint."
  value       = length(var.scc_wp_keys) > 0 ? ibm_resource_key.scc_wp_keys[keys(var.scc_wp_keys)[0]].credentials["Sysdig Collector Endpoint"] : null
  sensitive   = true
}

output "sysdig_endpoint" {
  description = "Sysdig endpoint."
  value       = length(var.scc_wp_keys) > 0 ? ibm_resource_key.scc_wp_keys[keys(var.scc_wp_keys)[0]].credentials["Sysdig Endpoint"] : null
  sensitive   = true
}
