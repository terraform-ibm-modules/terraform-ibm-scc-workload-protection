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

output "account_type" {
  description = "The determined type of the IBM Cloud account."
  value       = module.account_type_check.account_type
}
