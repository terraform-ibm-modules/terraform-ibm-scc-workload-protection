# CDR example

<!-- BEGIN SCHEMATICS DEPLOY HOOK -->
<p>
  <a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=scc-workload-protection-cdr-example&repository=https://github.com/terraform-ibm-modules/terraform-ibm-scc-workload-protection/tree/main/examples/cdr">
    <img src="https://img.shields.io/badge/Deploy%20with%20IBM%20Cloud%20Schematics-0f62fe?style=flat&logo=ibm&logoColor=white&labelColor=0f62fe" alt="Deploy with IBM Cloud Schematics">
  </a><br>
  ℹ️ Ctrl/Cmd+Click or right-click on the Schematics deploy button to open in a new tab.
</p>
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
