// Tests in this file are run in the PR pipeline and the continuous testing pipeline
package test

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
)

const advancedExampleDir = "examples/advanced"
const basicExampleDir = "examples/basic"
const cdrExampleDir = "examples/cdr"
const rtCspmExampleDir = "examples/rt_cspm"

func setupOptions(t *testing.T, prefix string, dir string) *testhelper.TestOptions {
	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:                    t,
		TerraformDir:               dir,
		Prefix:                     prefix,
		CheckApplyResultForUpgrade: true,
	})
	return options
}

func TestRunBasicExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "scc-wp", basicExampleDir)

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunAdvancedExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "scc-wp-adv", advancedExampleDir)
	options.TerraformVars = map[string]any{
		"existing_app_config_crn": permanentResources["app_config_crn"],
	}

	output, err := options.RunTest()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunCDRExample(t *testing.T) {
	t.Parallel()

	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:                    t,
		TerraformDir:               cdrExampleDir,
		Prefix:                     "scc-wp-cdr",
		CheckApplyResultForUpgrade: true,
		Region:                     getRandomRegion(),
	})
	options.TerraformVars = map[string]any{
		"existing_app_config_crn": permanentResources["app_config_crn"],
	}

	options.IgnoreUpdates = testhelper.Exemptions{
		List: []string{
			"module.scc_wp_cdr.module.cdr[0].module.code_engine_app.ibm_code_engine_app.ce_app",
		},
	}

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunRTCSPMExample(t *testing.T) {

	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:                    t,
		TerraformDir:               rtCspmExampleDir,
		Prefix:                     "rt-cspm",
		CheckApplyResultForUpgrade: true,
		Region:                     getRandomRegion(),
	})

	options.IgnoreUpdates = testhelper.Exemptions{
		List: []string{
			"module.scc_wp.module.rt_cspm[0].module.code_engine_app[0].ibm_code_engine_app.ce_app",
		},
	}

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}
