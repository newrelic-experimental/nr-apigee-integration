#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

cd $SCRIPT_DIR

# Create a property set
./props.sh -c

# Sharedflows
echo "Deploying sharedflows..."
echo "Deploying nr-instrumentation-obfuscation-sharedflow..."
cd $SCRIPT_DIR/sharedflows/src/gateway/nr-instrumentation-obfuscate-sharedflow
./deploy.sh
echo "Deploying nr-instrumentation-sharedflow..."
cd $SCRIPT_DIR/sharedflows/src/gateway/nr-instrumentation-sharedflow
./deploy.sh
echo "Deploying nr-log-api-sharedflow..."
cd $SCRIPT_DIR/sharedflows/src/gateway/nr-log-api-sharedflow
./deploy.sh
echo "Deploying nr-logging-api-sharedflow..."
cd $SCRIPT_DIR/sharedflows/src/gateway/nr-logging-sharedflow
./deploy.sh
echo "Deploying nr-metric-sharedflow..."
cd $SCRIPT_DIR/sharedflows/src/gateway/nr-metric-api-sharedflow
./deploy.sh
echo "Deploying nr-trace-api-sharedflow..."
cd $SCRIPT_DIR/sharedflows/src/gateway/nr-trace-api-sharedflow
./deploy.sh
echo "Completed deploying sharedflows"

# Examples
echo "Deploying examples..."
echo "Deploying newrelic-logging example proxy..."
cd $SCRIPT_DIR/examples/newrelic-logging
./deploy.sh
echo "Deploying newrelic-metric example proxy..."
cd $SCRIPT_DIR/examples/newrelic-metric
./deploy.sh
echo "Deploying newrelic-trace example proxy..."
cd $SCRIPT_DIR/examples/newrelic-trace
./deploy.sh
echo "Deploying newrelic-trace-and-logging example proxy..."
cd $SCRIPT_DIR/examples/newrelic-trace-and-logging
./deploy.sh
echo "Deploying newrelic-trace-and-metric example proxy..."
cd $SCRIPT_DIR/examples/newrelic-trace-and-metric-and-log
./deploy.sh
echo "Deploying newrelic-trace-and-metric-and-log-obfuscate example proxy..."
cd $SCRIPT_DIR/examples/newrelic-trace-and-metric-and-log-obfuscate
./deploy.sh
echo "Completed deploying examples"
