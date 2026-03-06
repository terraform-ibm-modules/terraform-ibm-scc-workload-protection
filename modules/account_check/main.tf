locals {
  # Set account_type variable from the external data source's JSON output.
  account_type  = data.external.account_check.result.account_type
  binaries_path = "/tmp"
}

data "external" "install_required_binaries" {
  count   = var.install_required_binaries ? 1 : 0
  program = ["/bin/bash", "${path.module}/../scripts/install-binaries.sh", local.binaries_path]
}

data "external" "account_check" {
  depends_on = [data.external.install_required_binaries]
  program    = ["/bin/bash", "${path.module}/../scripts/account-check.sh", local.binaries_path]
  query = {
    account_id = var.target_account_id
    iam_token  = var.iam_token
  }
}
