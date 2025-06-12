terraform {
  required_version = ">= 1.9.0"
  required_providers {
    # Use latest version of provider in non-basic examples to verify latest version works with module
    ibm = {
      source  = "ibm-cloud/ibm"
      version = ">=1.79.0, <2.0.0"
    }
    restapi = {
      source  = "Mastercard/restapi"
      version = ">=2.0.1, <3.0.0"
    }
  }
}
