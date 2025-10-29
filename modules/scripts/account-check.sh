#!/bin/bash

get_enterprise_endpoint() {
    default_endpoint="enterprise.cloud.ibm.com"
    enterprise_endpoint="${IBMCLOUD_ENTERPRISE_API_ENDPOINT:-"$default_endpoint"}"
    ENTERPRISE_ENDPOINT=${enterprise_endpoint#https://}
}

get_enterprise_endpoint

read -r TF_INPUT
ACCOUNT_ID=$(echo "$TF_INPUT" | jq -r '.account_id')
IAM_TOKEN=$(echo "$TF_INPUT" | jq -r '.iam_token')

URL="https://${ENTERPRISE_ENDPOINT}/v1/accounts/${ACCOUNT_ID}"

HTTP_CODE=$(curl -s -o /tmp/account.json -w "%{http_code}" \
  -X GET "$URL" \
  -H "Authorization: ${IAM_TOKEN}" 2>/dev/null)

ACCOUNT_TYPE="ACCOUNT"

if [ "$HTTP_CODE" == "200" ] && grep -q '"enterprise_id"' /tmp/account.json 2>/dev/null; then
  ACCOUNT_TYPE="ENTERPRISE"
fi

echo "{\"account_type\": \"${ACCOUNT_TYPE}\"}"

rm -f /tmp/account.json

exit 0
