# CDR (Cloud Detection and Response)

This submodule creates the infrastructure required for forwarding Activity Tracker events to IBM Cloud Security and Compliance Center Workload Protection for Cloud Detection and Response (CDR) compliance scanning.

## Architecture

The module sets up an end-to-end pipeline:

1. **Activity Tracker → COS**: Routes activity logs to Cloud Object Storage bucket
2. **COS → Code Engine**: Triggers Code Engine app on bucket write events
3. **Code Engine App**: Forwards events to SCC Workload Protection ingestion endpoint
4. **SCC-WP**: Analyzes events and triggers alerts for potential security risks

## Prerequisites

- IBM Cloud CLI installed and authenticated
- IBM Cloud Code Engine CLI plugin installed (`ibmcloud ce version`)
- Existing SCC Workload Protection instance with trusted profile and CSPM enabled

### Usage

```hcl
module "cdr" {
  source  = "terraform-ibm-modules/scc-workload-protection/ibm//modules/cdr"
  version = "X.X.X" # Replace with a release version

  # IBM Cloud Authentication
  ibmcloud_api_key = var.ibmcloud_api_key # sensitive

  # Basic Configuration
  region            = "us-south"
  resource_group_id = "xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX"

  # IAM Service ID
  iam_service_id_name = "cdr-service-id"

  # Cloud Object Storage
  cos_instance_name = "cdr-cos-instance"
  cos_bucket_name   = "cdr-events-bucket"

  # Trusted Profile
  trusted_profile_name = "cdr-trusted-profile"

  # SCC Workload Protection
  target_account_id        = "xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX"
  sysdig_environment_url   = "us-south.security-compliance-secure.cloud.ibm.com"
  workload_protection_crn  = "crn:v1:bluemix:public:sysdig-secure:us-south:a/xxxx:xxxx::"
  workload_protection_guid = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

  # Code Engine
  ce_project_name = "cdr-code-engine-project"
}
```


### Required IAM access policies

You need the following permissions to run this module:

- Account Management
  - **IAM Identity Service** service
      - `Administrator` platform access - Required to create Service IDs, API keys, and Trusted Profiles
  - **IAM Access Management** service
      - `Administrator` platform access - Required to create IAM policies and service-to-service authorizations

- IBM Cloud Services
  - **Activity Tracker Event Routing** service
      - `Editor` or `Administrator` platform access - Required to create Activity Tracker targets and routes
  - **Cloud Object Storage** service
      - `Manager` service access - Required to create and manage COS instances and buckets
  - **Code Engine** service
      - `Editor` or `Manager` service access - Required to create Code Engine projects, apps, and subscriptions
  - **Container Registry** service
      - `Reader` service access - Required for Code Engine to pull the CDR application image
  - **IBM Cloud Security and Compliance Center Workload Protection** service
      - `Editor` or `Administrator` platform access - Required to configure and manage Workload Protection instances

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
