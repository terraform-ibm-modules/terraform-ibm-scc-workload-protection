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
  description = "CRN of the App Configuration instance used for RT CSPM."
  value       = local.app_config_crn
}

##############################################################################
# Event Notifications Outputs
##############################################################################

output "event_notifications_crn" {
  description = "CRN of the Event Notifications instance."
  value       = local.event_notifications_crn
}
