# CDR and RT CSPM example

<!-- BEGIN SCHEMATICS DEPLOY HOOK -->
<p>
  <a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=scc-workload-protection-cdr_and_rt_cspm-example&repository=https://github.com/terraform-ibm-modules/terraform-ibm-scc-workload-protection/tree/main/examples/cdr_and_rt_cspm">
    <img src="https://img.shields.io/badge/Deploy%20with%20IBM%20Cloud%20Schematics-0f62fe?style=flat&logo=ibm&logoColor=white&labelColor=0f62fe" alt="Deploy with IBM Cloud Schematics">
  </a><br>
  ℹ️ Ctrl/Cmd+Click or right-click on the Schematics deploy button to open in a new tab.
</p>
<!-- END SCHEMATICS DEPLOY HOOK -->

An end-to-end example that enables both Cloud Detection and Response (CDR) and Real-Time Cloud Security Posture Management (RT CSPM) on the same Security and Compliance Center Workload Protection instance. When CDR is enabled, the root module configures RT CSPM to reuse the CDR infrastructure, so nothing is duplicated. This example uses the IBM Cloud terraform provider to:

- Create a new resource group if one is not passed in.
- Create a Security and Compliance Center Workload Protection instance with CSPM, CDR and RT CSPM enabled. An existing App Configuration instance (`app_config_crn`) and Event Notifications instance (`rt_cspm_event_notifications_crn`) are required.
- Set up the CDR infrastructure, which is shared with RT CSPM:
  - Cloud Object Storage instance and bucket
  - IAM Service ID with API key for authentication
  - Trusted Profile for secure access
  - Code Engine project and application for event forwarding
  - COS event subscription to trigger the Code Engine app
  - Activity Tracker Event Routing COS target and route (CDR only)
- Set up the additional RT CSPM resources:
  - Activity Tracker Event Routing App Configuration target and route
  - Service-to-service authorization policies (Activity Tracker to App Configuration, Event Notifications to COS)
  - Event Notifications topic, COS destination and subscription that write into the CDR bucket

An `ibmcloud_api_key` is required to manage the Code Engine COS subscription.
