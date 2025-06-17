# Enterprise example with CSPM enabled

The following example shows how to configure IBM Cloud Security and Compliance Center Workload Protection for Cloud Security Posture Management (CSPM) in an enterprise.

- Use the App Config module to create an App Config instance with configuration aggregator enabled. This module will also create a trusted profile with viewer / reader access for all Account Management and Identity and Access enabled services. It will also create a trusted profile template which will be applied to the given enterprise sub-accounts to scan the resources in those accounts.
- Use the Security and Compliance Center Workload Protection module to create a new instance of SCC Workload Protection with Cloud Security Posture Management (CSPM) enabled. The module will also create a trusted profile with viewer access to the App Config instance in order to be able to populate the inventory.
