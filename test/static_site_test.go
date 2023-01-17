package test

import (
	"fmt"
	"testing"
	"time"

	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestTerraformAwsHelloWorldExample(t *testing.T) {
	t.Parallel()

	// website::tag::2:: Construct the terraform options with default retryable errors to handle the most common
	// retryable errors in terraform testing.
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// website::tag::1:: The path to where our Terraform code is located
		TerraformDir: "../terraform",
	})

	// website::tag::6:: At the end of the test, run `terraform destroy` to clean up any resources that were created.
	defer terraform.Destroy(t, terraformOptions)

	// website::tag::3:: Run `terraform init` and `terraform apply`. Fail the test if there are any errors.
	terraform.InitAndApply(t, terraformOptions)

	// website::tag::4:: Run `terraform output` to get the IP of the instance
	url := terraform.Output(t, terraformOptions, "url")
	tlsConfig := tls.Config{}

	// website::tag::5:: Make an HTTPS request to the instance and make sure we get back a 200 OK with the body "Hello, World!"
	httpsUrl := fmt.Sprintf("https://%s", url)
	httpUrl := fmt.Sprintf("http://%s", url)
	http_helper.HttpGetWithRetry(t, url, &tlsConfig, 200, "Hello, World!", 30, 5*time.Second)
	http_helper.HttpGetWithRetry(t, url, nil, 301, "301 Moved Permanently", 30, 5*time.Second)
}