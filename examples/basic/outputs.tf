########################################################################################################################
# Outputs
########################################################################################################################

output "id" {
  description = "ID of created SCC WP instance."
  value       = module.scc_wp.id
}

output "guid" {
  description = "GUID of created SCC WP instance."
  value       = module.scc_wp.guid
}

output "crn" {
  description = "CRN of created SCC WP instance."
  value       = module.scc_wp.crn
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

output "access_key" {
  description = "Workload Protection instance access key."
  value       = module.scc_wp.access_key
  sensitive   = true
}

output "account_type" {
  description = "The determined type of the IBM Cloud account."
  value       = module.scc_wp.account_type
}
