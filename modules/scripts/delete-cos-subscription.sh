#!/usr/bin/env bash
##############################################################################
# Delete Code Engine COS Subscription
#
# This script deletes a Code Engine COS subscription during Terraform destroy.
#
# Required Environment Variables:
#   REGION            - IBM Cloud region
#   RESOURCE_GROUP    - Resource group ID
#   PROJECT_ID        - Code Engine project ID
#   SUBSCRIPTION_NAME - Name of the subscription to delete
##############################################################################

set -e
set -o pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Validate required environment variables
validate_env_vars() {
    local missing_vars=()
    
    [[ -z "${IBMCLOUD_API_KEY}" ]] && missing_vars+=("IBMCLOUD_API_KEY")
    [[ -z "${REGION}" ]] && missing_vars+=("REGION")
    [[ -z "${RESOURCE_GROUP}" ]] && missing_vars+=("RESOURCE_GROUP")
    [[ -z "${PROJECT_ID}" ]] && missing_vars+=("PROJECT_ID")
    [[ -z "${SUBSCRIPTION_NAME}" ]] && missing_vars+=("SUBSCRIPTION_NAME")
    
    if [[ ${#missing_vars[@]} -gt 0 ]]; then
        log_error "Missing required environment variables: ${missing_vars[*]}"
        exit 1
    fi
}

# Log in to IBM Cloud
ibmcloud_login() {
    log_info "Logging in to IBM Cloud..."
    local max_attempts=3
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        log_info "Login attempt ${attempt}/${max_attempts}..."
        if ibmcloud login --apikey "${IBMCLOUD_API_KEY}" -r "${REGION}" -g "${RESOURCE_GROUP}" --quiet 2>/dev/null; then
            log_info "Login successful"
            return 0
        fi
        
        if [ $attempt -lt $max_attempts ]; then
            log_warn "Login failed. Retrying in 3 seconds..."
            sleep 3
        fi
        attempt=$((attempt + 1))
    done
    
    log_warn "Failed to login to IBM Cloud after ${max_attempts} attempts. Resources may already be deleted."
    exit 0
}

# Select Code Engine project
select_project() {
    log_info "Selecting Code Engine project: ${PROJECT_ID}"
    if ! ibmcloud ce project select --id "${PROJECT_ID}" 2>/dev/null; then
        log_warn "Failed to select Code Engine project. Project may have been deleted."
        exit 0
    fi
}

# Delete COS subscription
delete_subscription() {
    log_info "Deleting Code Engine COS subscription: ${SUBSCRIPTION_NAME}"
    
    if ! ibmcloud ce subscription cos delete --name "${SUBSCRIPTION_NAME}" --force 2>/dev/null; then
        log_warn "Failed to delete subscription '${SUBSCRIPTION_NAME}'. It may not exist or was already deleted."
        exit 0
    fi
    
    log_info "Subscription deleted successfully"
}

# Main execution
main() {
    log_info "Starting Code Engine COS subscription deletion..."
    
    validate_env_vars
    ibmcloud_login
    select_project
    delete_subscription
    
    log_info "Script completed successfully"
}

# Run main function
main "$@"
