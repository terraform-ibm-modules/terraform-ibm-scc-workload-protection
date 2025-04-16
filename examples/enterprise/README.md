# Complete Example: SCC-WP with App Config and Trusted Profiles

> Only supported in an enterprise account.

This example demonstrates the full deployment of:

- IBM Cloud App Configuration
- IBM Cloud Security and Compliance Center Workload Protection (SCC-WP)
- IAM Trusted Profile Template with 3 Trusted Profiles
- Template assignment to account groups
- Configuration Aggregator to link SCC-WP with App Config

---

## Flow Overview

1. **Create or reuse a resource group**  
   A resource group is created or reused.

2. **Deploy App Config**  
   App Config is deployed along with a collection for organizing features and properties.

3. **Deploy SCC Workload Protection**  
   SCC-WP is deployed with the `graduated-tier` plan.

4. **Create a Trusted Profile Template with 3 profiles**
   - **App Config -- Enterprise**  
     For IAM template management across the enterprise.
   - **App Config -- General**  
     For reading platform and IAM services.
   - **SCC-WP Profile**  
     For integrating SCC-WP with App Config and enterprise usage.

5. **Assign the template to account groups**  
   All child accounts or specific account groups receive the profile template.

6. **Create SCC-WP Config Aggregator**  
   The aggregator connects SCC-WP to App Config and uses the enterprise trusted profile and template ID to enforce secure access.

---

## Notes

- The `trusted_profile_links` block in each trusted profile is used to **link the profile to a specific CRN**, like a VSI or App Config instance, enabling the identity to assume the trusted profile.

---

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.3.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement_ibm) | >= 1.76.1, < 2.0.0 |

---

## Usage

```bash
terraform init
terraform apply
```

---


