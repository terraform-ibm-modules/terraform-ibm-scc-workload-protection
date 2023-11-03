########################################################################################################################
# Outputs
########################################################################################################################

output "collector_host" {
  description = "Collector host."
  value       = module.scc_wp.collector_host
}

output "api_endpoint" {
  description = "API endpoint."
  value       = module.scc_wp.api_endpoint
}

output "crn" {
  description = "CRN of created SCC WP instance."
  value       = module.scc_wp.crn
}

output "name" {
  description = "Name of created SCC WP instance."
  value       = module.scc_wp.name
}
