terraform {
  required_version = ">= 1.9.0"
  required_providers {
    ibm = {
      source  = "ibm-cloud/ibm"
      version = ">= 2.9.0, < 3.0.0"
    }
    sysdig = {
      source  = "sysdiglabs/sysdig"
      version = ">= 3.3.1, <4.0.0"
    }
  }
}
