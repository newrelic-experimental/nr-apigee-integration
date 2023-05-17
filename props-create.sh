#!/bin/bash
TOKEN=$(gcloud auth print-access-token)
ORG=${APIGEE_ORG:-"default here if not set as an env variable"}
ENV=${APIGEE_ENV:-"default here if not set as an env variable"}
NAME=NRTracePropSet

curl -X POST "https://apigee.googleapis.com/v1/organizations/$ORG/environments/$ENV/resourcefiles?name=$NAME&type=properties" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-type: multipart/form-data" \
  -F file=@nrtrace.properties