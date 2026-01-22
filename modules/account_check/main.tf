locals {
  # Set account_type variable from the external data source's JSON output.
  account_type = data.external.account_check.result.account_type
  binaries_path = "/tmp"
}

resource "terraform_data" "install_required_binaries" {
  count = var.install_required_binaries ? 1 : 0

  provisioner "local-exec" {
    command     = "${path.module}/scripts/install-binaries.sh ${local.binaries_path}"
    interpreter = ["/bin/bash", "-c"]
  }
}

data "external" "account_check" {
  program = ["/bin/bash", "${path.module}/../scripts/account-check.sh ${local.binaries_path}"]
  query = {
    account_id = var.target_account_id
    iam_token  = var.iam_token
  }
}
