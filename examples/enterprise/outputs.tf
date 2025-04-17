output "scc_wp_crn" {
  description = "CRN of the SCC Workload Protection instance"
  value       = module.scc_wp.crn
}

output "trusted_profile_template_id" {
  description = "Trusted profile template ID"
  value       = module.trusted_profile_template.trusted_profile_template_id
}

output "trusted_profile_enterprise_id" {
  description = "Trusted profile enterprise ID"
  value       = module.trusted_profile_app_config_enterprise.profile_id
}

output "app_config_guid" {
  description = "App Config guid"
  value       = module.app_config.app_config_guid
}

output "app_config_crn" {
  description = "App Config CRN"
  value       = module.app_config.app_config_crn
}
