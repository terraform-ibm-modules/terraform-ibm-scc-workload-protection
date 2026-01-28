#!/bin/bash
set -e

# The binaries downloaded by the install-binaries script are located in the /tmp directory.
export PATH=$PATH:${1:-"/tmp"}

check_dependencies() {
    if ! command -v jq &> /dev/null; then
        echo "Error: 'jq' is required but not found. Please install 'jq' to run this script." >&2
        exit 1
    fi
}

check_dependencies

get_enterprise_endpoint() {
    default_endpoint="enterprise.cloud.ibm.com"
    enterprise_endpoint="${IBMCLOUD_ENTERPRISE_API_ENDPOINT:-"$default_endpoint"}"
    ENTERPRISE_ENDPOINT=${enterprise_endpoint#https://}
}

get_enterprise_endpoint

read -r TF_INPUT || true
ACCOUNT_ID=$(echo "$TF_INPUT" | jq -r '.account_id')
IAM_TOKEN=$(echo "$TF_INPUT" | jq -r '.iam_token')

URL="https://${ENTERPRISE_ENDPOINT}/v1/accounts/${ACCOUNT_ID}"

CURL_OUTPUT=$(curl -s -w "STATUS_CODE:%{http_code}" \
  --retry 3 \
  -X GET "$URL" \
  -H "Authorization: ${IAM_TOKEN}")

HTTP_CODE=$(echo "$CURL_OUTPUT" | grep -o 'STATUS_CODE:[0-9]*$' | awk -F: '{print $2}')

RESPONSE_BODY=${CURL_OUTPUT%STATUS_CODE:*}

ACCOUNT_TYPE="ACCOUNT"

if [ "$HTTP_CODE" == "200" ] && echo "$RESPONSE_BODY" | grep -q '"enterprise_id"'; then
  ACCOUNT_TYPE="ENTERPRISE"
fi

echo "{\"account_type\": \"${ACCOUNT_TYPE}\"}"

exit 0
