##############################################################################
# CDR Module Outputs
##############################################################################

##############################################################################
# Cloud Object Storage Outputs
##############################################################################

output "cos_instance_id" {
  description = "ID of the COS instance created for CDR"
  value       = module.cos.cos_instance_id
}

output "cos_instance_crn" {
  description = "CRN of the COS instance created for CDR"
  value       = module.cos.cos_instance_crn
}

output "cos_instance_guid" {
  description = "GUID of the COS instance created for CDR"
  value       = module.cos.cos_instance_guid
}

output "cos_bucket_name" {
  description = "Name of the COS bucket for Activity Tracker events"
  value       = module.cos_bucket.buckets[var.cos_bucket_name].bucket_name
}

output "cos_bucket_id" {
  description = "ID of the COS bucket"
  value       = module.cos_bucket.buckets[var.cos_bucket_name].bucket_id
}

output "cos_bucket_crn" {
  description = "CRN of the COS bucket"
  value       = module.cos_bucket.buckets[var.cos_bucket_name].bucket_crn
}

##############################################################################
# Activity Tracker Outputs
##############################################################################

output "atracker_target_id" {
  description = "ID of the Activity Tracker target"
  value       = module.activity_tracker.activity_tracker_targets[var.atracker_target_name].id
}

output "atracker_target_crn" {
  description = "CRN of the Activity Tracker target"
  value       = module.activity_tracker.activity_tracker_targets[var.atracker_target_name].crn
}

output "atracker_route_id" {
  description = "ID of the Activity Tracker route"
  value       = module.activity_tracker.activity_tracker_routes[var.atracker_route_name].id
}

##############################################################################
# Service ID Outputs
##############################################################################

output "service_id" {
  description = "IAM ID of the service ID created for CDR"
  value       = module.cdr_service_id.iam_id
}

output "service_id_crn" {
  description = "CRN of the service ID created for CDR"
  value       = module.cdr_service_id.service_id
}

output "service_api_key" {
  description = "API key for CDR service authentication"
  value       = module.cdr_service_id.service_id_apikey
  sensitive   = true
}

output "service_policy_ids" {
  description = "List of service policy IDs"
  value       = module.cdr_service_id.service_policy_ids
}

##############################################################################
# Code Engine Outputs
##############################################################################

output "code_engine_project_id" {
  description = "ID of the Code Engine project"
  value       = module.code_engine_project.project_id
}

output "code_engine_secrets" {
  description = "Code Engine secrets created for CDR"
  value       = module.code_engine_project.secret
  sensitive   = true
}

output "code_engine_app" {
  description = "Code Engine app details for CDR"
  value       = module.code_engine_app.name
}

output "code_engine_app_url" {
  description = "URL of the Code Engine app"
  value       = module.code_engine_app.endpoint
}

##############################################################################
# CDR Configuration Outputs
##############################################################################

output "cdr_ingestion_url" {
  description = "Sysdig ingestion URL for CDR events"
  value       = local.ingestion_url
  sensitive   = true
}

##############################################################################
# CDR Trusted Profile Outputs
##############################################################################

output "trusted_profile_id" {
  description = "ID of the CDR trusted profile"
  value       = module.cdr_trusted_profile.profile_id
}

output "trusted_profile_name" {
  description = "Name of the CDR trusted profile"
  value       = module.cdr_trusted_profile.trusted_profile.name
}

output "trusted_profile_policies" {
  description = "List of policies attached to the CDR trusted profile"
  value       = module.cdr_trusted_profile.trusted_profile_policies
}
