// Tests in this file are run in the PR pipeline and the continuous testing pipeline
package test

import (
	"log"
	"os"
	"testing"

	"math/rand/v2"

	"github.com/stretchr/testify/assert"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/common"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testschematic"
)

const resourceGroup = "geretain-test-resources"
const standardSolutionDir = "solutions/standard"

// Define a struct with fields that match the structure of the YAML data.
const yamlLocation = "../common-dev-assets/common-go-assets/common-permanent-resources.yaml"

// Current supported SCC region
var validRegions = []string{
	"us-south",
	"eu-de",
	"ca-tor",
	"eu-es",
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

func TestInstancesInSchematics(t *testing.T) {
	t.Parallel()

	var region = validRegions[rand.IntN(len(validRegions))]

	options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
		Testing: t,
		Prefix:  "wp-da",
		TarIncludePatterns: []string{
			"*.tf",
			standardSolutionDir + "/*.tf",
		},
		ResourceGroup:          resourceGroup,
		TemplateFolder:         standardSolutionDir,
		Tags:                   []string{"test-schematic"},
		DeleteWorkspaceOnFail:  false,
		WaitJobCompleteMinutes: 60,
	})

	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		{Name: "resource_group_name", Value: options.Prefix, DataType: "string"},
		{Name: "scc_region", Value: region, DataType: "string"},
		{Name: "scc_workload_protection_instance_tags", Value: options.Tags, DataType: "list(string)"},
		{Name: "scc_workload_protection_resource_key_tags", Value: options.Tags, DataType: "list(string)"},
		{Name: "scc_workload_protection_access_tags", Value: permanentResources["accessTags"], DataType: "list(string)"},
		{Name: "prefix", Value: options.Prefix, DataType: "string"},
	}

	err := options.RunSchematicTest()
	assert.Nil(t, err, "This should not have errored")
}

func TestRunUpgradeInstances(t *testing.T) {
	t.Parallel()

	var region = validRegions[rand.IntN(len(validRegions))]

	options := testhelper.TestOptionsDefault(&testhelper.TestOptions{
		Testing:      t,
		TerraformDir: standardSolutionDir,
		Prefix:       "wp-da-upg",
	})

	options.TerraformVars = map[string]interface{}{
		"prefix":                                options.Prefix,
		"resource_group_name":                   options.Prefix,
		"scc_region":                            region,
		"scc_workload_protection_instance_tags": options.Tags,
		"scc_workload_protection_resource_key_tags": options.Tags,
		"scc_workload_protection_access_tags":       permanentResources["accessTags"],
	}

	output, err := options.RunTestUpgrade()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, output, "Expected some output")
	}
}
