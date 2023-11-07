terraform {
  required_version = ">= 1.3.0, <1.6.0"
  required_providers {
    # Use "greater than or equal to" range in modules
    ibm = {
      source  = "ibm-cloud/ibm"
      version = ">= 1.58.1, <2.0.0"
    }
  }
}
