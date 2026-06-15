# CDR example

<!-- BEGIN SCHEMATICS DEPLOY HOOK -->
<!-- END SCHEMATICS DEPLOY HOOK -->

An end-to-end example that demonstrates Cloud Detection and Response (CDR) functionality. This example uses the IBM Cloud terraform provider to:

- Create a new resource group if one is not passed in.
- Create a Key Protect instance with encryption keys for COS bucket encryption.
- Create an App Configuration instance (required for CSPM).
- Create a Security and Compliance Center Workload Protection instance with both CSPM and CDR enabled.
- Set up the complete CDR infrastructure:
  - Cloud Object Storage instance and bucket with KMS encryption
  - Activity Tracker Event Routing target and route
  - IAM Service ID with API key for authentication
  - Trusted Profile for secure access
  - Code Engine project and application for event forwarding
  - COS event subscription to trigger the Code Engine app
  - Integration with SCC Workload Protection for security event analysis