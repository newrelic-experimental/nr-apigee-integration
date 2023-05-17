# Synthetics monitors
This directory contains Terraform configuration to create synthetics monitors to exercise the sample API proxies.

The scripts call the proxy urls with [W3C Trace Context](https://www.w3.org/TR/trace-context/) headers: traceparent, and tracestate.

## Installation
Make sure Terraform is installed. We recommend [tfenv](https://github.com/tfutils/tfenv) for managing your Terraform binaries.

Update the [runtf.sh.sample](runtf.sh.sample) wrapper file with your credentials and account details and rename it `runtf.sh`. **Important do not commit this new file to git!** (It should be ignored in `.gitignore` already.)

The wrapper file contains configuration of three API keys:
1.  `NEW_RELIC_API_KEY`: a User API key to create Terraform resources
2.  `TF_VAR_apigee_protocol`: the protocol used by the Apigee proxy, e.g. https
3.  `TF_VAR_apigee_host`: the IP address or FQDN of the Apigee endpoint

Note: You may want to update the version numbers in [provider.tf](provider.tf) to the latest versions of Terraform and the New Relic provider.