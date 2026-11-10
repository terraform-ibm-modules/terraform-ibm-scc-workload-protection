##############################################################################
# RT CSPM Module Outputs
##############################################################################

##############################################################################
# Cloud Object Storage Outputs
##############################################################################

output "cos_instance_id" {
  description = "ID of the COS instance created by RT CSPM. Null when CDR infrastructure is used (CDR owns the COS bucket)."
  value       = try(module.cos[0].cos_instance_id, null)
}

output "cos_instance_crn" {
  description = "CRN of the COS instance created by RT CSPM. Null when CDR infrastructure is used."
  value       = try(module.cos[0].cos_instance_crn, null)
}

output "cos_instance_guid" {
  description = "GUID of the COS instance that stores RT CSPM notification archives (the CDR instance when CDR infrastructure is used)"
  value       = local.cos_instance_guid
}

output "cos_bucket_name" {
  description = "Name of the COS bucket that stores RT CSPM notification archives (the CDR bucket when CDR infrastructure is used)"
  value       = local.cos_bucket_name
}

output "cos_bucket_id" {
  description = "ID of the COS bucket created by RT CSPM. Null when CDR infrastructure is used."
  value       = try(module.cos[0].bucket_id, null)
}

output "cos_bucket_crn" {
  description = "CRN of the COS bucket created by RT CSPM. Null when CDR infrastructure is used."
  value       = try(module.cos[0].bucket_crn, null)
}

##############################################################################
# Activity Tracker Outputs
##############################################################################

output "atracker_target_id" {
  description = "ID of the Activity Tracker target that delivers events to App Configuration"
  value       = ibm_atracker_target.appconfig.id
}

output "atracker_target_crn" {
  description = "CRN of the Activity Tracker target"
  value       = ibm_atracker_target.appconfig.crn
}

output "atracker_route_id" {
  description = "ID of the Activity Tracker route"
  value       = ibm_atracker_route.rt_cspm.id
}

##############################################################################
# Event Notifications Outputs
##############################################################################

output "event_notifications_topic_id" {
  description = "ID of the Event Notifications topic that filters App Configuration aggregator events"
  value       = ibm_en_topic.rt_cspm.topic_id
}

output "event_notifications_destination_id" {
  description = "ID of the Event Notifications COS destination"
  value       = ibm_en_destination_cos.cos.destination_id
}

output "event_notifications_subscription_id" {
  description = "ID of the Event Notifications COS subscription"
  value       = ibm_en_subscription_cos.cos.subscription_id
}

##############################################################################
# Service ID Outputs
##############################################################################

output "service_id" {
  description = "ID of the service ID used by RT CSPM. Null when CDR infrastructure is used."
  value       = local.effective_service_id
}

output "service_api_key" {
  description = "API key of the service ID used by RT CSPM. Null when CDR infrastructure is used."
  value       = local.effective_service_apikey
  sensitive   = true
}

##############################################################################
# Trusted Profile Outputs
##############################################################################

output "trusted_profile_id" {
  description = "ID of the trusted profile used by RT CSPM. Null when CDR infrastructure is used."
  value       = local.effective_trusted_profile_id
}

##############################################################################
# Code Engine Outputs
##############################################################################

output "code_engine_project_id" {
  description = "ID of the Code Engine project used by RT CSPM. Null when CDR infrastructure is used."
  value       = local.effective_ce_project_id
}

output "code_engine_app" {
  description = "Name of the Code Engine app that forwards RT CSPM events. Null when CDR infrastructure is used."
  value       = try(module.code_engine_app[0].name, null)
}

output "code_engine_app_url" {
  description = "URL of the Code Engine app. Null when CDR infrastructure is used."
  value       = try(module.code_engine_app[0].endpoint, null)
}

##############################################################################
# RT CSPM Configuration Outputs
##############################################################################

output "rt_cspm_ingestion_endpoint" {
  description = "Sysdig ingestion URL for RT CSPM events. Null when CDR infrastructure is used."
  value       = local.rt_cspm_ingestion_endpoint
  sensitive   = true
}
