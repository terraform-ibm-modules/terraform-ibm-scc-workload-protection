locals {
  # Set account_type variable from the external data source's JSON output.
  account_type = data.external.account_check.result.account_type
}

data "external" "account_check" {
  program = ["/bin/bash", "${path.module}/../scripts/account-check.sh"]
  query = {
    account_id = var.target_account_id
    iam_token  = var.iam_token
  }
}
