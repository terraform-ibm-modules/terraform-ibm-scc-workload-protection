########################################################################################################################
# Outputs
########################################################################################################################

output "id" {
  description = "ID of created SCC WP instance."
  value       = module.scc_wp.id
}

output "name" {
  description = "Name of created SCC WP instance."
  value       = module.scc_wp.name
}

output "ingestion_endpoint" {
  description = "Ingestion endpoint."
  value       = module.scc_wp.ingestion_endpoint
  sensitive   = true
}

output "api_endpoint" {
  description = "API endpoint."
  value       = module.scc_wp.api_endpoint
  sensitive   = true
}
