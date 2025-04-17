# Enterprise Example: SCC-WP with App Config and Trusted Profiles

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

## Usage

```bash
terraform init
terraform apply
```

---

## Known issue

There is a [known issue](https://github.com/IBM-Cloud/terraform-provider-ibm/issues/6164) which you will face if you attempt a re-apply of this example after the initial apply has complete.

- The `ibm_iam_trusted_profile_template` will detect a update in place which looks something like this:
   ```
   Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
   ~ update in-place

   Terraform will perform the following actions:

   # module.trusted_profile_template.ibm_iam_trusted_profile_template.trusted_profile_template_instance will be updated in-place
   ~ resource "ibm_iam_trusted_profile_template" "trusted_profile_template_instance" {
         id                  = "ProfileTemplate-8b16cb82-b9b4-434a-b678-12c82033e9a7/1"
         name                = "Trusted Profile Template for SCC-WP"
         # (11 unchanged attributes hidden)

         ~ profile {
               name        = "Trusted Profile for IBM Cloud CSPM in SCC-WP"
               # (1 unchanged attribute hidden)

            ~ identities {
               ~ iam_id      = "crn-crn:v1:bluemix:public:apprapp:us-south:a/1f27e30e31f0486980cb0b2657d483f7:c89c16ce-3505-453e-8990-c7473657779b::" -> "crn:v1:bluemix:public:apprapp:us-south:a/1f27e30e31f0486980cb0b2657d483f7:c89c16ce-3505-453e-8990-c7473657779b::"
                  # (4 unchanged attributes hidden)
               }
         }

         # (2 unchanged blocks hidden)
      }
   ```
- Any account groups that were assigned the trusted profile template will also see an update in place. For example:
   ```
   # module.trusted_profile_template.ibm_iam_trusted_profile_template_assignment.account_settings_template_assignment_instance["AccountGroup-3596923e5a674a7fa7eb01c5b17fce8e"] will be updated in-place
   ~ resource "ibm_iam_trusted_profile_template_assignment" "account_settings_template_assignment_instance" {
         id                  = "TemplateAssignment-befcf82f-6bd2-4922-b2c1-5c161685488c"
         + resources           = (known after apply)
         # (13 unchanged attributes hidden)
      }
   ```
- If you then proceed with the apply, it will fail with the following error:
   ```
   module.trusted_profile_template.ibm_iam_trusted_profile_template.trusted_profile_template_instance: Modifying... [id=ProfileTemplate-8b16cb82-b9b4-434a-b678-12c82033e9a7/1]
   ╷
   │ Error: UpdateProfileTemplateVersionWithContext failed Template in committed state.
   │ {
   │     "StatusCode": 422,
   │     "Headers": {
   │         "Akamai-Grn": [
   │             "0.bdb01302.1744900183.cacb5e65"
   │         ],
   │         "Cache-Control": [
   │             "no-cache, no-store, must-revalidate"
   │         ],
   │         "Content-Language": [
   │             "en-US"
   │         ],
   │         "Content-Length": [
   │             "334"
   │         ],
   │         "Content-Type": [
   │             "application/json"
   │         ],
   │         "Date": [
   │             "Thu, 17 Apr 2025 14:29:43 GMT"
   │         ],
   │         "Expires": [
   │             "0"
   │         ],
   │         "Ibm-Cloud-Service-Name": [
   │             "iam-identity"
   │         ],
   │         "Pragma": [
   │             "no-cache"
   │         ],
   │         "Set-Cookie": [
   │             "ak_bmsc=540034860F090FE00019133754696C9B~000000000000000000000000000000~YAAQvbATAmL0BRuWAQAA59YnRBuMehleeYJJD1yOUDM/362Yj0eaMmjUwIsm8G4Muf/XUfjIHA5XJGWRI1lc21CDcPI7yVqdHcX5h4l59hxg+cqzHDBeNUIojafPY7k82U8X9ECSo5XFuyfFx4tlSOVclDZ05o2vLfNlpsi+Gr8kBbwySy/XGjfPi5g0ZLRq1Segl+vK7mV2HNdboRRw2MKdZpxYUgIrx/WhFgsuIgZBx6xzDLVjLYZHfFhZ1pF/s/vgOC9pPv8oAOxbas8pvR0hfeL4/9tNLiqws2kMal8wDeuytpy0qEzFLvlFRTa9YG0GYXthz5MxlA/VX5fnxfPcc7SGW2dTu1JFYKig/SapnDnqJCo/n/YlJLrjfguPWQjK; Domain=.cloud.ibm.com; Path=/; Expires=Thu, 17 Apr 2025 16:29:43 GMT; Max-Age=7200"
   │         ],
   │         "Strict-Transport-Security": [
   │             "max-age=31536000; includeSubDomains"
   │         ],
   │         "Transaction-Id": [
   │             "OXRxZ2M-8c573b755d4f4a28bb60756766ea1c64"
   │         ],
   │         "X-Content-Type-Options": [
   │             "nosniff"
   │         ],
   │         "X-Correlation-Id": [
   │             "OXRxZ2M-8c573b755d4f4a28bb60756766ea1c64"
   │         ],
   │         "X-Proxy-Upstream-Service-Time": [
   │             "127"
   │         ],
   │         "X-Request-Id": [
   │             "81085e6c-1d77-4916-84c5-e4574956e456"
   │         ]
   │     },
   │     "Result": {
   │         "errors": [
   │             {
   │                 "code": "invalid_state",
   │                 "details": "Unable to process this request as Template with ID 'ProfileTemplate-8b16cb82-b9b4-434a-b678-12c82033e9a7' and version '1' is in a committed state.",
   │                 "message": "Template in committed state.",
   │                 "message_code": "BXNIM0908E"
   │             }
   │         ],
   │         "status_code": 422,
   │         "trace": "OXRxZ2M-8c573b755d4f4a28bb60756766ea1c64"
   │     },
   │     "RawResult": null
   │ }
   │
   │
   │   with module.trusted_profile_template.ibm_iam_trusted_profile_template.trusted_profile_template_instance,
   │   on .terraform/modules/trusted_profile_template/modules/trusted-profile-template/main.tf line 26, in resource "ibm_iam_trusted_profile_template" "trusted_profile_template_instance":
   │   26: resource "ibm_iam_trusted_profile_template" "trusted_profile_template_instance" {
   ```
