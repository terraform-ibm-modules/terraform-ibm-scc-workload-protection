# Enterprise example with CSPM enabled

<!-- BEGIN SCHEMATICS DEPLOY HOOK -->
<a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=scc-workload-protection-enterprise-example&repository=https://github.com/terraform-ibm-modules/terraform-ibm-scc-workload-protection/tree/main/examples/enterprise"><img src="https://img.shields.io/badge/Deploy%20with IBM%20Cloud%20Schematics-0f62fe?logo=ibm&logoColor=white&labelColor=0f62fe" alt="Deploy with IBM Cloud Schematics" style="height: 16px; vertical-align: text-bottom;"></a>
<!-- END SCHEMATICS DEPLOY HOOK -->

:warning: In order for enterprise sub-accounts to be scanned, you must turn on **enterprise-managed IAM** to centrally manage access and IAM settings for the sub-accounts. [Learn more](https://cloud.ibm.com/docs/enterprise-management?topic=enterprise-management-enterprise-managed-opt-in).

The following example shows how to configure IBM Cloud Security and Compliance Center Workload Protection for Cloud Security Posture Management (CSPM) in an enterprise.

- Use the App Config module to create an App Config instance with configuration aggregator enabled. This module will also create a trusted profile with viewer / reader access for all Account Management and Identity and Access enabled services. It will also create a trusted profile template which will be applied to the given enterprise sub-accounts to scan the resources in those accounts.
- Use the Security and Compliance Center Workload Protection module to create a new instance of SCC Workload Protection with Cloud Security Posture Management (CSPM) enabled. The module will also create a trusted profile with viewer access to the App Config instance in order to be able to populate the inventory.
- Create a new [Zone](https://cloud.ibm.com/docs/workload-protection?topic=workload-protection-posture-zones) in the Workload Protection instance, add policies to it. You can use a scope to scope it to particular account IDs.

<!-- BEGIN SCHEMATICS DEPLOY TIP HOOK -->
:information_source: Ctrl/Cmd+Click or right-click on the Schematics deploy button to open in a new tab
<!-- END SCHEMATICS DEPLOY TIP HOOK -->
