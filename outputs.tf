########################################################################################################################
# Outputs
########################################################################################################################

output "name" {
  description = "Name of created SCC WP instance."
  value       = ibm_resource_instance.scc_wp.name
}

output "id" {
  description = "ID of created SCC WP instance."
  value       = ibm_resource_instance.scc_wp.id
}

output "ingestion_endpoint" {
  description = "Ingestion endpoint."
  value       = ibm_resource_key.scc_wp_resource_key.credentials["Sysdig Collector Endpoint"]
  sensitive   = true
}

output "api_endpoint" {
  description = "API endpoint."
  value       = ibm_resource_key.scc_wp_resource_key.credentials["Sysdig Endpoint"]
  sensitive   = true
}
