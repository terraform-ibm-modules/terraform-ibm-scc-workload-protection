variable "iam_token" {
  description = "The IBM Cloud platform IAM token needed to authenticate deploy IAM enabled resources."
  type        = string
  sensitive   = true
}

variable "target_account_id" {
  description = "The ID of the target account to check for type."
  type        = string
}
