# Complete Example: SCC-WP with App Config and Trusted Profiles

This example demonstrates the full deployment of:

- IBM Cloud App Configuration
- IBM Cloud Security and Compliance Center Workload Protection (SCC-WP)
- IAM Trusted Profile Template with 3 Trusted Profiles
- Template assignment to account groups
- Configuration Aggregator to link SCC-WP with App Config

---

## Flow Overview

1. Create or reuse a resource group  
   A resource group is created.

2. Deploy App Config  
   App Config is deployed along with a collection for organizing features and properties.

3. Deploy SCC Workload Protection  
   SCC-WP is deployed with the `graduated-tier` plan (customizable via variable).

4. Create a Trusted Profile Template with 3 profiles
   - App Config - Enterprise  
     For IAM template management across the enterprise.
   - App Config - General  
     For reading platform and IAM services.
   - SCC-WP Profile  
     For integrating SCC-WP with App Config and enterprise usage.

5. Assign the template to account groups  

6. Create SCC-WP Config Aggregator  
   The aggregator connects SCC-WP to App Config and uses the enterprise trusted profile and template ID to enforce secure access.

---

## Usage

terraform init
terraform apply

