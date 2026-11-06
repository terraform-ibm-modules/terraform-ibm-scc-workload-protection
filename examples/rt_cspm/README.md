# RT CSPM example

<!-- BEGIN SCHEMATICS DEPLOY HOOK -->
<p>
  <a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=scc-workload-protection-rt_cspm-example&repository=https://github.com/terraform-ibm-modules/terraform-ibm-scc-workload-protection/tree/main/examples/rt_cspm">
    <img src="https://img.shields.io/badge/Deploy%20with%20IBM%20Cloud%20Schematics-0f62fe?style=flat&logo=ibm&logoColor=white&labelColor=0f62fe" alt="Deploy with IBM Cloud Schematics">
  </a><br>
  ℹ️ Ctrl/Cmd+Click or right-click on the Schematics deploy button to open in a new tab.
</p>
<!-- END SCHEMATICS DEPLOY HOOK -->

An end-to-end example that demonstrates Real-Time Cloud Security Posture Management (RT CSPM) functionality, with Cloud Detection and Response (CDR) disabled. This example uses the IBM Cloud terraform provider to:

- Create a new resource group if one is not passed in.
- Create an Event Notifications instance.
- Create an App Configuration instance with the config aggregator and Event Notifications integration enabled (required for CSPM and RT CSPM).
- Create a Security and Compliance Center Workload Protection instance with CSPM and RT CSPM enabled.
- Set up the complete RT CSPM infrastructure:
  - Activity Tracker Event Routing App Configuration target and route
  - Service-to-service authorization policies (Activity Tracker to App Configuration, Event Notifications to COS)
  - Event Notifications topic, COS destination and subscription
  - Cloud Object Storage instance and bucket to archive notifications
  - IAM Service ID with API key for authentication
  - Trusted Profile for secure access
  - Code Engine project and application for event forwarding
  - COS event subscription to trigger the Code Engine app
  - Integration with SCC Workload Protection for security event analysis
