########################################################################################################################
# Outputs
########################################################################################################################

output "crn" {
  description = "CRN of created SCC WP instance."
  value       = module.scc_wp.id
}

output "name" {
  description = "Name of created SCC WP instance."
  value       = module.scc_wp.name
}

output "sysdig_collector_endpoint" {
  description = "Sysdig collector endpoint."
  value       = module.scc_wp.sysdig_collector_endpoint
  sensitive   = true
}

output "sysdig_endpoint" {
  description = "Sysdig endpoint."
  value       = module.scc_wp.sysdig_endpoint
  sensitive   = true
}
