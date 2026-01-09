# Advanced example

An end-to-end example that uses the module's default variable values. This example uses the IBM Cloud terraform provider to:

- Create a new resource group if one is not passed in.
- Create a new IBM Cloud monitoring instance.
- Create a new Security and Compliance Center Workload Protection instance and connect it with IBM Cloud monitoring instance.
- Create a new [Zone](https://cloud.ibm.com/docs/workload-protection?topic=workload-protection-posture-zones) in the Workload Protection instance, add policies to it, and scope it to an account.
