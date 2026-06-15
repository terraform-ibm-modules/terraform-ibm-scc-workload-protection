##############################################################################
# Outputs
##############################################################################

output "scc_wp_id" {
  description = "ID of the SCC Workload Protection instance"
  value       = module.scc_wp_cdr.id
}

output "scc_wp_crn" {
  description = "CRN of the SCC Workload Protection instance"
  value       = module.scc_wp_cdr.crn
}

output "scc_wp_name" {
  description = "Name of the SCC Workload Protection instance"
  value       = module.scc_wp_cdr.name
}

# output "sysdig_endpoint" {
#   description = "endpoint."
#   value       = module.scc_wp_cdr.sysdig_endpoint
# }

output "cdr_cos_bucket_name" {
  description = "Name of the COS bucket for Activity Tracker events"
  value       = module.scc_wp_cdr.cdr_cos_bucket_name
}

output "cdr_cos_instance_crn" {
  description = "CRN of the COS instance created for CDR"
  value       = module.scc_wp_cdr.cdr_cos_instance_crn
}

output "cdr_atracker_target_id" {
  description = "ID of the Activity Tracker target"
  value       = module.scc_wp_cdr.cdr_atracker_target_id
}

output "cdr_atracker_target_crn" {
  description = "CRN of the Activity Tracker target"
  value       = module.scc_wp_cdr.cdr_atracker_target_crn
}

output "cdr_atracker_route_id" {
  description = "ID of the Activity Tracker route"
  value       = module.scc_wp_cdr.cdr_atracker_route_id
}

output "cdr_code_engine_project_id" {
  description = "ID of the Code Engine project"
  value       = module.scc_wp_cdr.cdr_code_engine_project_id
}

output "cdr_code_engine_secrets" {
  description = "Code Engine secrets created for CDR"
  value       = module.scc_wp_cdr.cdr_code_engine_secrets
  sensitive   = true
}

output "cdr_code_engine_app" {
  description = "Code Engine app details for CDR"
  value       = module.scc_wp_cdr.cdr_code_engine_app
}

output "cdr_code_engine_app_url" {
  description = "URL of the Code Engine app"
  value       = module.scc_wp_cdr.cdr_code_engine_app_url
}

output "cdr_service_id" {
  description = "IAM ID of the service ID created for CDR"
  value       = module.scc_wp_cdr.cdr_service_id
}

output "cdr_service_id_crn" {
  description = "CRN of the service ID created for CDR"
  value       = module.scc_wp_cdr.cdr_service_id_crn
}

output "cdr_trusted_profile_id" {
  description = "ID of the CDR trusted profile"
  value       = module.scc_wp_cdr.cdr_trusted_profile_id
}

output "cdr_trusted_profile_name" {
  description = "Name of the CDR trusted profile"
  value       = module.scc_wp_cdr.cdr_trusted_profile_name
}
