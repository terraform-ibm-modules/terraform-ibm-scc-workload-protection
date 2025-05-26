output "scc_wp_crn" {
  description = "CRN of the SCC Workload Protection instance"
  value       = module.scc_wp.crn
}

output "trusted_profile_enterprise_id" {
  description = "Trusted profile enterprise ID"
  value       = var.enterprise_id
}

output "app_config_guid" {
  description = "App Config guid"
  value       = module.app_config.app_config_guid
}

output "app_config_crn" {
  description = "App Config CRN"
  value       = module.app_config.app_config_crn
}
