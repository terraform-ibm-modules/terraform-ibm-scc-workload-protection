#!/bin/bash

# This script is placed in the root module when it is invoked individually.
# Placing it here also avoids duplicating the install-binaries script across modules.

set -o errexit
set -o pipefail

DIRECTORY=${1:-"/tmp"}
export PATH="$PATH:$DIRECTORY"
# renovate: datasource=github-tags depName=terraform-ibm-modules/common-bash-library
TAG=v0.2.1
# Running multiple Terraform executions on the same environment that share a /tmp directory can lead to conflicts during script execution.
TMP_DIR=$(mktemp -d "${DIRECTORY}/common-bash-XXXXX")

echo "Downloading common-bash-library version ${TAG}."

# Calculate expected checksum by downloading from GitHub
echo "Calculating expected checksum from GitHub release..."
EXPECTED_SHA256=$(curl -sL "https://github.com/terraform-ibm-modules/common-bash-library/archive/refs/tags/${TAG}.tar.gz" | sha256sum | awk '{print $1}')

if [ -z "$EXPECTED_SHA256" ]; then
    echo "ERROR: Failed to calculate expected checksum from GitHub"
    rm -rf "$TMP_DIR"
    exit 1
fi

echo "Expected checksum: $EXPECTED_SHA256"

# download common-bash-library
curl --silent \
    --connect-timeout 5 \
    --max-time 10 \
    --retry 3 \
    --retry-delay 2 \
    --retry-connrefused \
    --fail \
    --show-error \
    --location \
    --output "${TMP_DIR}/common-bash.tar.gz" \
    "https://github.com/terraform-ibm-modules/common-bash-library/archive/refs/tags/$TAG.tar.gz"

# Verify SHA256 checksum matches the one we calculated from GitHub
echo "Verifying downloaded archive integrity..."
ACTUAL_SHA256=$(sha256sum "${TMP_DIR}/common-bash.tar.gz" | awk '{print $1}')

if [ "$ACTUAL_SHA256" != "$EXPECTED_SHA256" ]; then
    echo "ERROR: SHA256 checksum verification failed!"
    echo "Expected: $EXPECTED_SHA256"
    echo "Actual:   $ACTUAL_SHA256"
    echo "The downloaded archive may be compromised or corrupted."
    rm -rf "$TMP_DIR"
    exit 1
fi

echo "Checksum verified successfully."

mkdir -p "${TMP_DIR}/common-bash-library"
tar -xzf "${TMP_DIR}/common-bash.tar.gz" -C "${TMP_DIR}"
rm -f "${TMP_DIR}/common-bash.tar.gz"

# The file doesn’t exist at the time shellcheck runs, so this check is skipped.
# shellcheck disable=SC1091,SC1090
source "${TMP_DIR}/common-bash-library-${TAG#v}/common/common.sh"

echo "Installing jq."
install_jq "latest" "${DIRECTORY}" "true"

rm -rf "$TMP_DIR"

echo "Installation complete successfully"
