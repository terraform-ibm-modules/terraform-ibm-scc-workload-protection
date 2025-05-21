// Tests in this file are run in the PR pipeline and the continuous testing pipeline
package test

import (
	"fmt"
	"log"
	"os"
	"strings"
	"testing"

	"math/rand/v2"

	"github.com/gruntwork-io/terratest/modules/files"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/common"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testschematic"
)

const resourceGroup = "geretain-test-resources"
const fullyConfigurableDADir = "solutions/fully-configurable"

var existingResources = "./resources/existing-resources"

// Define a struct with fields that match the structure of the YAML data.
const yamlLocation = "../common-dev-assets/common-go-assets/common-permanent-resources.yaml"

// Current supported SCC Workload Protection region
var validRegions = []string{
	"us-south",
	"us-east",
	"eu-de",
	"eu-es",
	"eu-gb",
	"jp-osa",
	"jp-tok",
	"br-sao",
	"ca-tor",
	"au-syd",
}

var permanentResources map[string]interface{}

func TestMain(m *testing.M) {
	// Read the YAML file contents
	var err error
	permanentResources, err = common.LoadMapFromYaml(yamlLocation)
	if err != nil {
		log.Fatal(err)
	}

	os.Exit(m.Run())
}

func TestFullyConfigurable(t *testing.T) {
	t.Parallel()

	var region = validRegions[rand.IntN(len(validRegions))]

	// ------------------------------------------------------------------------------------
	// Provision App Config first
	// ------------------------------------------------------------------------------------

	prefix := fmt.Sprintf("wp-da-%s", strings.ToLower(random.UniqueId()))
	realTerraformDir := existingResources
	tempTerraformDir, _ := files.CopyTerraformFolderToTemp(realTerraformDir, fmt.Sprintf(prefix+"-%s", strings.ToLower(random.UniqueId())))
	tags := common.GetTagsFromTravis()

	// Verify ibmcloud_api_key variable is set
	checkVariable := "TF_VAR_ibmcloud_api_key"
	val, present := os.LookupEnv(checkVariable)
	require.True(t, present, checkVariable+" environment variable not set")
	require.NotEqual(t, "", val, checkVariable+" environment variable is empty")

	logger.Log(t, "Tempdir: ", tempTerraformDir)
	existingTerraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: tempTerraformDir,
		Vars: map[string]any{
			"prefix":        prefix,
			"region":        region,
			"resource_tags": tags,
		},
		// Set Upgrade to true to ensure latest version of providers and modules are used by terratest.
		// This is the same as setting the -upgrade=true flag with terraform.
		Upgrade: true,
	})

	terraform.WorkspaceSelectOrNew(t, existingTerraformOptions, prefix)
	_, existErr := terraform.InitAndApplyE(t, existingTerraformOptions)
	if existErr != nil {
		assert.True(t, existErr == nil, "Init and Apply of pre-req resources failed in TestFullyConfigurable test")
	} else {
		// ------------------------------------------------------------------------------------
		// Deploy DA
		// ------------------------------------------------------------------------------------
		options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
			Testing: t,
			Prefix:  "wp-da",
			TarIncludePatterns: []string{
				"*.tf",
				fullyConfigurableDADir + "/*.tf",
			},
			ResourceGroup:          resourceGroup,
			TemplateFolder:         fullyConfigurableDADir,
			Tags:                   []string{"test-schematic"},
			DeleteWorkspaceOnFail:  false,
			WaitJobCompleteMinutes: 60,
		})

		options.TerraformVars = []testschematic.TestSchematicTerraformVar{
			{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
			{Name: "existing_resource_group_name", Value: resourceGroup, DataType: "string"},
			{Name: "region", Value: region, DataType: "string"},
			{Name: "scc_workload_protection_instance_tags", Value: options.Tags, DataType: "list(string)"},
			{Name: "scc_workload_protection_resource_key_tags", Value: options.Tags, DataType: "list(string)"},
			{Name: "scc_workload_protection_access_tags", Value: permanentResources["accessTags"], DataType: "list(string)"},
			{Name: "prefix", Value: options.Prefix, DataType: "string"},
			{Name: "app_config_crn", Value: terraform.Output(t, existingTerraformOptions, "app_config_crn"), DataType: "string"},
		}
		err := options.RunSchematicTest()
		assert.Nil(t, err, "This should not have errored")
	}

	// Check if "DO_NOT_DESTROY_ON_FAILURE" is set
	envVal, _ := os.LookupEnv("DO_NOT_DESTROY_ON_FAILURE")
	// Destroy the temporary existing resources if required
	if t.Failed() && strings.ToLower(envVal) == "true" {
		fmt.Println("Terratest failed. Debug the test and delete resources manually.")
	} else {
		logger.Log(t, "START: Destroy (prereq resources)")
		terraform.Destroy(t, existingTerraformOptions)
		terraform.WorkspaceDelete(t, existingTerraformOptions, prefix)
		logger.Log(t, "END: Destroy (prereq resources)")
	}
}

func TestFullyConfigurableUpgrade(t *testing.T) {
	t.Parallel()

	var region = validRegions[rand.IntN(len(validRegions))]

	// ------------------------------------------------------------------------------------
	// Provision App Config first
	// ------------------------------------------------------------------------------------

	prefix := fmt.Sprintf("wp-da-%s", strings.ToLower(random.UniqueId()))
	realTerraformDir := existingResources
	tempTerraformDir, _ := files.CopyTerraformFolderToTemp(realTerraformDir, fmt.Sprintf(prefix+"-%s", strings.ToLower(random.UniqueId())))
	tags := common.GetTagsFromTravis()

	// Verify ibmcloud_api_key variable is set
	checkVariable := "TF_VAR_ibmcloud_api_key"
	val, present := os.LookupEnv(checkVariable)
	require.True(t, present, checkVariable+" environment variable not set")
	require.NotEqual(t, "", val, checkVariable+" environment variable is empty")

	logger.Log(t, "Tempdir: ", tempTerraformDir)
	existingTerraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: tempTerraformDir,
		Vars: map[string]interface{}{
			"prefix":        prefix,
			"region":        region,
			"resource_tags": tags,
		},
		// Set Upgrade to true to ensure latest version of providers and modules are used by terratest.
		// This is the same as setting the -upgrade=true flag with terraform.
		Upgrade: true,
	})

	terraform.WorkspaceSelectOrNew(t, existingTerraformOptions, prefix)
	_, existErr := terraform.InitAndApplyE(t, existingTerraformOptions)
	if existErr != nil {
		assert.True(t, existErr == nil, "Init and Apply of pre-req resources failed in TestFullyConfigurable test")
	} else {
		// ------------------------------------------------------------------------------------
		// Deploy DA
		// ------------------------------------------------------------------------------------
		options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
			Testing: t,
			Prefix:  "wp-da",
			TarIncludePatterns: []string{
				"*.tf",
				fullyConfigurableDADir + "/*.tf",
			},
			ResourceGroup:          resourceGroup,
			TemplateFolder:         fullyConfigurableDADir,
			Tags:                   []string{"test-schematic"},
			DeleteWorkspaceOnFail:  false,
			WaitJobCompleteMinutes: 60,
		})

		options.TerraformVars = []testschematic.TestSchematicTerraformVar{
			{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
			{Name: "existing_resource_group_name", Value: resourceGroup, DataType: "string"},
			{Name: "region", Value: region, DataType: "string"},
			{Name: "scc_workload_protection_instance_tags", Value: options.Tags, DataType: "list(string)"},
			{Name: "scc_workload_protection_resource_key_tags", Value: options.Tags, DataType: "list(string)"},
			{Name: "scc_workload_protection_access_tags", Value: permanentResources["accessTags"], DataType: "list(string)"},
			{Name: "prefix", Value: options.Prefix, DataType: "string"},
			{Name: "app_config_crn", Value: terraform.Output(t, existingTerraformOptions, "app_config_crn"), DataType: "string"},
		}
		err := options.RunSchematicUpgradeTest()
		if !options.UpgradeTestSkipped {
			assert.Nil(t, err, "This should not have errored")
		}
	}

	// Check if "DO_NOT_DESTROY_ON_FAILURE" is set
	envVal, _ := os.LookupEnv("DO_NOT_DESTROY_ON_FAILURE")
	// Destroy the temporary existing resources if required
	if t.Failed() && strings.ToLower(envVal) == "true" {
		fmt.Println("Terratest failed. Debug the test and delete resources manually.")
	} else {
		logger.Log(t, "START: Destroy (prereq resources)")
		terraform.Destroy(t, existingTerraformOptions)
		terraform.WorkspaceDelete(t, existingTerraformOptions, prefix)
		logger.Log(t, "END: Destroy (prereq resources)")
	}
}
