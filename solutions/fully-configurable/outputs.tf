
########################################################################################################################
# Outputs
########################################################################################################################

output "resource_group_name" {
  description = "Resource group name"
  value       = module.resource_group.resource_group_name
}

output "resource_group_id" {
  description = "Resource group ID"
  value       = module.resource_group.resource_group_id
}

output "scc_workload_protection_id" {
  description = "SCC Workload Protection instance ID"
  value       = module.scc_wp.id
}

output "scc_workload_protection_crn" {
  description = "SCC Workload Protection instance CRN"
  value       = module.scc_wp.crn
}

output "scc_workload_protection_name" {
  description = "SCC Workload Protection instance name"
  value       = module.scc_wp.name
}

output "scc_workload_protection_ingestion_endpoint" {
  description = "SCC Workload Protection instance ingestion endpoint"
  value       = module.scc_wp.name
}

output "scc_workload_protection_api_endpoint" {
  description = "SCC Workload Protection API endpoint"
  value       = module.scc_wp.api_endpoint
  sensitive   = true
}

output "scc_workload_protection_access_key" {
  description = "SCC Workload Protection access key"
  value       = module.scc_wp.access_key
  sensitive   = true
}

output "next_steps_text" {
  value       = "You can now configure the agent and start using Security and Compliance Center Workload Protection."
  description = "Next steps text"
}

output "next_step_primary_label" {
  value       = "Go to SCC Workload Protection"
  description = "Primary label"
}

output "next_step_primary_url" {
  value       = "https://cloud.ibm.com/workload-protection/${module.scc_wp.guid}/overview"
  description = "Primary URL"
}

output "next_step_secondary_label" {
  value       = "Learn more about SCC Workload Protection"
  description = "Secondary label"
}

output "next_step_secondary_url" {
  value       = "https://cloud.ibm.com/docs/workload-protection?topic=workload-protection-getting-started"
  description = "Secondary URL"
}
