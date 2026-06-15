########################################################################################################################
# Outputs
########################################################################################################################

output "name" {
  description = "Name of created SCC WP instance."
  value       = ibm_resource_instance.scc_wp.name
}

output "id" {
  description = "ID of created SCC WP instance."
  value       = ibm_resource_instance.scc_wp.id
}

output "guid" {
  description = "GUID of created SCC WP instance."
  value       = ibm_resource_instance.scc_wp.guid
}

output "crn" {
  description = "CRN of created SCC WP instance."
  value       = ibm_resource_instance.scc_wp.crn
}

output "account_id" {
  description = "Account ID of created SCC WP instance."
  value       = ibm_resource_instance.scc_wp.account_id
}

output "ingestion_endpoint" {
  description = "Ingestion endpoint."
  value       = ibm_resource_key.scc_wp_resource_key.credentials["Sysdig Collector Endpoint"]
  sensitive   = true
}

output "api_endpoint" {
  description = "API endpoint."
  value       = ibm_resource_key.scc_wp_resource_key.credentials["Sysdig Endpoint"]
  sensitive   = true
}

output "access_key" {
  description = "Workload Protection instance access key."
  value       = ibm_resource_key.scc_wp_resource_key.credentials["Sysdig Access Key"]
  sensitive   = true
}

##############################################################################
# CDR Module Outputs
##############################################################################

output "cdr_cos_instance_id" {
  description = "ID of the COS instance created for CDR"
  value       = var.cdr_enabled ? module.cdr[0].cos_instance_id : null
}

output "cdr_cos_instance_crn" {
  description = "CRN of the COS instance created for CDR"
  value       = var.cdr_enabled ? module.cdr[0].cos_instance_crn : null
}

output "cdr_cos_instance_guid" {
  description = "GUID of the COS instance created for CDR"
  value       = var.cdr_enabled ? module.cdr[0].cos_instance_guid : null
}

output "cdr_cos_bucket_name" {
  description = "Name of the COS bucket for Activity Tracker events"
  value       = var.cdr_enabled ? module.cdr[0].cos_bucket_name : null
}

output "cdr_cos_bucket_id" {
  description = "ID of the COS bucket"
  value       = var.cdr_enabled ? module.cdr[0].cos_bucket_id : null
}

output "cdr_cos_bucket_crn" {
  description = "CRN of the COS bucket"
  value       = var.cdr_enabled ? module.cdr[0].cos_bucket_crn : null
}

output "cdr_atracker_target_id" {
  description = "ID of the Activity Tracker target"
  value       = var.cdr_enabled ? module.cdr[0].atracker_target_id : null
}

output "cdr_atracker_target_crn" {
  description = "CRN of the Activity Tracker target"
  value       = var.cdr_enabled ? module.cdr[0].atracker_target_crn : null
}

output "cdr_atracker_route_id" {
  description = "ID of the Activity Tracker route"
  value       = var.cdr_enabled ? module.cdr[0].atracker_route_id : null
}

output "cdr_service_id" {
  description = "IAM ID of the service ID created for CDR"
  value       = var.cdr_enabled ? module.cdr[0].service_id : null
}

output "cdr_service_id_crn" {
  description = "CRN of the service ID created for CDR"
  value       = var.cdr_enabled ? module.cdr[0].service_id_crn : null
}

output "cdr_service_api_key" {
  description = "API key for CDR service authentication"
  value       = var.cdr_enabled ? module.cdr[0].service_api_key : null
  sensitive   = true
}

output "cdr_service_policy_ids" {
  description = "List of service policy IDs"
  value       = var.cdr_enabled ? module.cdr[0].service_policy_ids : null
}

output "cdr_code_engine_project_id" {
  description = "ID of the Code Engine project"
  value       = var.cdr_enabled ? module.cdr[0].code_engine_project_id : null
}

output "cdr_code_engine_secrets" {
  description = "Code Engine secrets created for CDR"
  value       = var.cdr_enabled ? module.cdr[0].code_engine_secrets : null
  sensitive   = true
}

output "cdr_code_engine_app" {
  description = "Code Engine app details for CDR"
  value       = var.cdr_enabled ? module.cdr[0].code_engine_app : null
}

output "cdr_code_engine_app_url" {
  description = "URL of the Code Engine app"
  value       = var.cdr_enabled ? module.cdr[0].code_engine_app_url : null
}

output "cdr_ingestion_url" {
  description = "Sysdig ingestion URL for CDR events"
  value       = var.cdr_enabled ? module.cdr[0].cdr_ingestion_url : null
  sensitive   = true
}

output "cdr_trusted_profile_id" {
  description = "ID of the CDR trusted profile"
  value       = var.cdr_enabled ? module.cdr[0].trusted_profile_id : null
}

output "cdr_trusted_profile_name" {
  description = "Name of the CDR trusted profile"
  value       = var.cdr_enabled ? module.cdr[0].trusted_profile_name : null
}

output "cdr_trusted_profile_policies" {
  description = "List of policies attached to the CDR trusted profile"
  value       = var.cdr_enabled ? module.cdr[0].trusted_profile_policies : null
}
