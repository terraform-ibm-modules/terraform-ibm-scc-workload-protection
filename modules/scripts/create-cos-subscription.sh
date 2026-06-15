#!/usr/bin/env bash
##############################################################################
# Create Code Engine COS Subscription
#
# This script creates a Code Engine COS subscription that triggers the CDR
# application when objects are written to the COS bucket.
#
# Required Environment Variables:
#   REGION            - IBM Cloud region
#   RESOURCE_GROUP    - Resource group ID
#   PROJECT_ID        - Code Engine project ID
#   APP_NAME          - Code Engine app name
#   BUCKET_NAME       - COS bucket name
#   SUBSCRIPTION_NAME - Name for the subscription
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
    [[ -z "${APP_NAME}" ]] && missing_vars+=("APP_NAME")
    [[ -z "${BUCKET_NAME}" ]] && missing_vars+=("BUCKET_NAME")
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
        if ibmcloud login --apikey "${IBMCLOUD_API_KEY}" -r "${REGION}" -g "${RESOURCE_GROUP}" --quiet; then
            log_info "Login successful"
            return 0
        fi

        if [ $attempt -lt $max_attempts ]; then
            log_warn "Login failed. Retrying in 3 seconds..."
            sleep 3
        fi
        attempt=$((attempt + 1))
    done

    log_error "Failed to login to IBM Cloud after ${max_attempts} attempts"
    exit 1
}

# Select Code Engine project
select_project() {
    log_info "Selecting Code Engine project: ${PROJECT_ID}"
    if ! ibmcloud ce project select --id "${PROJECT_ID}"; then
        log_error "Failed to select Code Engine project"
        exit 1
    fi
}

# Check if subscription already exists
subscription_exists() {
    if ibmcloud ce subscription cos get --name "${SUBSCRIPTION_NAME}" &>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Create COS subscription
create_subscription() {
    log_info "Creating Code Engine COS subscription: ${SUBSCRIPTION_NAME}"
    log_info "  Destination: ${APP_NAME} (app)"
    log_info "  Bucket: ${BUCKET_NAME}"
    log_info "  Event type: write"

    if ! ibmcloud ce subscription cos create \
        --name "${SUBSCRIPTION_NAME}" \
        --destination "${APP_NAME}" \
        --destination-type app \
        --bucket "${BUCKET_NAME}" \
        --event-type write; then
        log_error "Failed to create COS subscription"
        exit 1
    fi

    log_info "Subscription created successfully"
}

# Main execution
main() {
    log_info "Starting Code Engine COS subscription creation..."

    validate_env_vars
    ibmcloud_login
    select_project

    if subscription_exists; then
        log_warn "Subscription '${SUBSCRIPTION_NAME}' already exists. Skipping creation."
        log_info "To update the subscription, delete it first and re-run this script."
    else
        create_subscription
    fi

    log_info "Script completed successfully"
}

# Run main function
main "$@"
