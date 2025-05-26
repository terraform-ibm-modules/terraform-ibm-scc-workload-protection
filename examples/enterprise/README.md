# Enterprise Example: SCC-WP with App Config and Trusted Profiles

> Only supported in an enterprise account.

This example demonstrates a full deployment using modular Terraform code, including:

- **IBM Cloud App Configuration** (App Config)
- **IBM Cloud Security and Compliance Center Workload Protection** (SCC-WP)
- **IAM Trusted Profiles** for secure integration
- **Resource Group** creation or reuse
- **Configuration Aggregator** to link SCC-WP with App Config

---

## Module Overview

- **Resource Group Module**
  Creates or reuses a resource group for all resources.

- **SCC Workload Protection Module**
  Deploys the SCC-WP instance, attaches tags, and (optionally) enables CSPM and trusted profiles based on input variables.

- **App Config Module**
  Deploys an App Config instance with enterprise plan, tags, and enables the configuration aggregator with a trusted profile.

---

## Flow Overview

1. **Resource Group**
   A resource group is created or reused for all resources.

2. **App Config**
   Deploys App Config with the enterprise plan, tags, and enables the configuration aggregator with a trusted profile.

3. **SCC Workload Protection**
   Deploys SCC-WP with the `graduated-tier` plan, attaches resource and access tags, and (optionally) enables CSPM and trusted profiles for secure integration.

4. **Trusted Profiles**
   Trusted profiles are created and linked as needed for App Config and SCC-WP, with enterprise access policies conditionally included if enabled.

5. **Configuration Aggregator**
   Connects SCC-WP to App Config using the trusted profile and template ID for secure access across the enterprise.

---

## Notes

- The `trusted_profile_links` block in each trusted profile links the profile to a specific CRN (e.g., VSI or App Config instance), enabling the identity to assume the trusted profile.
- Enterprise-specific access policies are conditionally added based on input variables (e.g., `enterprise_enabled`).

---

## Usage

```bash
terraform init
terraform apply
```

---
