terraform {
  required_version = ">= 1.9.0"
  # Lock DA into an exact provider version - renovate automation will keep it updated
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "2.9.0"
    }
    # Only needed to remove the old restapi_object.cspm from the state of existing deployments.
    restapi = {
      source  = "Mastercard/restapi"
      version = "2.0.1"
    }
  }
}
