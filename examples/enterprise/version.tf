terraform {
  required_version = ">= 1.3.0"
  required_providers {
    ibm = {
      source  = "ibm-cloud/ibm"
      version = ">= 1.70.0, < 2.0.0"
    }
    restapi = {
      source  = "Mastercard/restapi"
      version = ">=1.20.0, <2.0.0"
    }
  }
}
