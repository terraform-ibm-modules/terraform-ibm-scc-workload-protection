########################################################################################################################
# Outputs
########################################################################################################################

output "api_endpoint" {
  description = "API endpoint."
  value       = "${var.region}.security-compliance-secure.cloud.ibm.com"
}

output "collector_host" {
  description = "Collector host."
  value       = "ingest.${var.region}.security-compliance-secure.cloud.ibm.com"
}

output "name" {
  description = "Name of created SCC WP instance."
  value       = ibm_resource_instance.scc_wp.name
}

output "crn" {
  description = "CRN of created SCC WP instance."
  value       = ibm_resource_instance.scc_wp.crn
}
