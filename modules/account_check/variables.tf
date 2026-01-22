variable "iam_token" {
  description = "The IBM Cloud platform IAM token needed to authenticate deploy IAM enabled resources."
  type        = string
  sensitive   = true
}

variable "target_account_id" {
  description = "The ID of the target account to check for type."
  type        = string
}

variable "install_required_binaries" {
    type        = bool  
    default     = true  
    description = "When set to true, a script will run to check if `jq` exist on the runtime and if not attempt to download it from the public internet and install it to /tmp. Set to false to skip running this script."  
    nullable    = false
}