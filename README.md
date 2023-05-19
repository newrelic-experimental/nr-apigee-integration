# nr-apigee-integration
This repository contains reusable configuration to provide observability of [Apigee](https://cloud.google.com/apigee/docs/api-platform/get-started/what-apigee) proxies through New Relic, using [W3C Trace Context](https://www.w3.org/TR/trace-context/) distributed tracing and logs in context.

## Overview
TBC

## Installation
Assumes an Apigee-X environment, but there is no reason this shouldn't work with Apigee Edge, aside from credentials.
### Prerequisites
* [maven](https://maven.apache.org/) - the deployment of proxies makes use of the [apigee-deploy-maven-plugin](https://github.com/apigee/apigee-deploy-maven-plugin)
* [gcloud CLI](https://cloud.google.com/sdk/docs/install)

### Configuration properties file
Update the [newrelic.properties.sample](newrelic.properties.sample) properties file to provide the configuration for your environment, and rename it `newrelic.properties`. **Important do not commit this new file to git!** (It should be ignored in `.gitignore` already.)
The newrelic.properties file contains the following value:
* LICENSE_KEY: your New Relic [Ingest License API key](https://docs.newrelic.com/docs/apis/intro-apis/new-relic-api-keys/#license-key)

Create, or update a propertyset named `NewRelicPropSet` for your environment using [props-create.sh](props-create.sh), and [props-update.sh](props-update.sh) respectively. Use [props-get.sh](props-get.sh) to verify the property set has been created successfully. Use [props-delete.sh](props-delete.sh) to delete the property set.

### Maven configuration
If you are using the New Relic EU region, instead of the US region, change the host endpoint values.
* For logging edit the [config.json](sharedflows/src/gateway/nr-logging-sharedflow/config.json)file. Use either `newrelic.syslog.nr-data.net` or `newrelic.syslog.eu.nr-data.net` depending on whether your New Relic account is hosted in the US or EU region respectively  
* For tracing edit the [config.json](sharedflows/src/gateway/nr-w3c-trace-api-sharedflow/config.json) file. Use either `trace-api.newrelic.com` or `trace-api.eu.newrelic.com` depending on whether your New Relic account is hosted in the US or EU region respectively

To configure the slow requests auto sample time edit the [config.json](sharedflows/src/gateway/nr-w3c-trace-prepare-sharedflow/config.json) file. This is the time, in milliseconds, that will initiate auto-sampling of slow proxy requests. Suggested `5000`ms (5 seconds)

### Environment variables
Set the following environment variables:
* APIGEE_ORG: the name of your Apigee organization, e.g `silicon-shape-123456`
* APIGEE_ENV: your agigee environment. The proxies can be configured per environment, e.g. `dev`

If the environment variables are not set, they can alternatively be provided in the following file locations:
* [props-create.sh](props-create.sh), [props-update.sh](props-update.sh), and [props-get.sh](props-get.sh)
* deploy.sh for each of the proxies 

### Shared flows
The instrumentation examples in this repository make use of [shared flows](https://cloud.google.com/apigee/docs/api-platform/fundamentals/shared-flows).

Example API proxies are contained in the [examples](examples) directory. The example proxies are dependent on the following shared flows:
* nr-logging-sharedflow
* nr-w3c-trace-api-sharedflow
* nr-w3c-trace-prepare-sharedflow

To install the shared flows:
1. Execute the [deploy.sh](sharedflows/src/gateway/nr-w3c-trace-api-sharedflow/deploy.sh) script from within the [sharedflows/src/gateway/nr-w3c-trace-api-sharedflow](sharedflows/src/gateway/nr-w3c-trace-api-sharedflow) directory.
2. Execute the [deploy.sh](sharedflows/src/gateway/nr-w3c-trace-prepare-sharedflow/deploy.sh) script from within the [sharedflows/src/gateway/nr-w3c-trace-prepare-sharedflow](sharedflows/src/gateway/nr-w3c-trace-api-sharedflow) directory.
3. Execute the [deploy.sh](sharedflows/src/gateway/nr-logging-sharedflow/deploy.sh) script from within the [sharedflows/src/gateway/nr-logging-sharedflow](sharedflows/src/gateway/nr-logging-sharedflow) directory.

### Example flow
To install the example flows:
1. Execute the [deploy.sh](examples/newrelic-logging/deploy.sh) script from within the [examples/newrelic-logging](examples/newrelic-logging) directory.
2. Execute the [deploy.sh](examples/newrelic-trace/deploy.sh) script from within the [examples/newrelic-trace](examples/newrelic-trace) directory.
3. Execute the [deploy.sh](examples/newrelic-trace-and-logging/deploy.sh) script from within the [examples/newrelic-trace-and-logging](examples/newrelic-trace-and-logging) directory.

## Synthetics tests for the example API proxies
Terraform configuration is available to create synthetics monitors to exercise the sample API proxies. Take a look at the [README.md](synthetics-tests/README.md) file in the [synthetics-tests](synthetics-tests) directory for more information.

## Acknowledgements
The distributed tracing instrumentation code here owes much to the https://github.com/sri-shetty/DT-Apigee-Proxy repository.