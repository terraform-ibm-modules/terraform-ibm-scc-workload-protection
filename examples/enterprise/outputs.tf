output "scc_wp_crn" {
  description = "CRN of the SCC Workload Protection instance"
  value       = module.scc_wp.crn
}

output "trusted_profile_template_id" {
  value = module.trusted_profile_template.trusted_profile_template_id
}

output "trusted_profile_enterprise_id" {
  value = module.trusted_profile_app_config_enterprise.profile_id
}

output "app_config_guid" {
  value = module.app_config.app_config_guid
}

output "app_config_crn" {
  value = module.app_config.app_config_crn
}

