##############################################################################
# SCC Workload Protection Outputs
##############################################################################

output "scc_wp_id" {
  description = "ID of the SCC Workload Protection instance."
  value       = module.scc_wp.id
}

output "scc_wp_guid" {
  description = "GUID of the SCC Workload Protection instance."
  value       = module.scc_wp.guid
}

output "scc_wp_crn" {
  description = "CRN of the SCC Workload Protection instance."
  value       = module.scc_wp.crn
}

##############################################################################
# App Configuration Outputs
##############################################################################

output "app_config_crn" {
  description = "CRN of the App Configuration instance."
  value       = module.app_config.app_config_crn
}

##############################################################################
# Event Notifications Outputs
##############################################################################

output "event_notifications_crn" {
  description = "CRN of the Event Notifications instance."
  value       = module.event_notifications.crn
}

##############################################################################
# CDR Outputs
##############################################################################

output "cdr_cos_bucket_name" {
  description = "Name of the COS bucket used for CDR Activity Tracker events."
  value       = module.scc_wp.cdr_cos_bucket_name
}

output "cdr_trusted_profile_id" {
  description = "ID of the shared trusted profile (created by CDR, reused by RT CSPM)."
  value       = module.scc_wp.cdr_trusted_profile_id
}

output "cdr_code_engine_project_id" {
  description = "ID of the shared Code Engine project (created by CDR, reused by RT CSPM)."
  value       = module.scc_wp.cdr_code_engine_project_id
}

output "cdr_code_engine_app_url" {
  description = "URL of the CDR Code Engine application."
  value       = module.scc_wp.cdr_code_engine_app_url
}
