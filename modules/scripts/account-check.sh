#!/bin/bash

read -r TF_INPUT
ACCOUNT_ID=$(echo "$TF_INPUT" | jq -r '.account_id')
IBM_CLOUD_API_KEY=$(echo "$TF_INPUT" | jq -r '.api_key')

# --- Obtain IAM Token ---
IAM_TOKEN=$(curl -s -X POST "https://iam.cloud.ibm.com/identity/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=urn:ibm:params:oauth:grant-type:apikey&apikey=${IBM_CLOUD_API_KEY}" \
  | jq -r '.access_token')

# --- Query Enterprise API ---
HTTP_CODE=$(curl -s -w "%{http_code}" -o /tmp/account.json \
  -X GET "https://enterprise.cloud.ibm.com/v1/accounts/${ACCOUNT_ID}" \
  -H "Authorization: Bearer ${IAM_TOKEN}")

# --- Determine Account Type ---
ACCOUNT_TYPE="NORMAL"
if [ "$HTTP_CODE" == "200" ] && grep -q '"enterprise_id"' /tmp/account.json; then
  ACCOUNT_TYPE="ENTERPRISE"
fi

# --- Output for Terraform ---
echo "{\"account_type\": \"${ACCOUNT_TYPE}\"}"
exit 0
