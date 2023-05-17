TOKEN=$(gcloud auth print-access-token)
#!/bin/bash
TOKEN=$(gcloud auth print-access-token)
ORG=${APIGEE_ORG:-"default here if not set as an env variable"}
ENV=${APIGEE_ENV:-"default here if not set as an env variable"}
NAME=NRTracePropSet

curl -X GET "https://apigee.googleapis.com/v1/organizations/$ORG/environments/$ENV/resourcefiles/properties/$NAME" \
  -H "Authorization: Bearer $TOKEN"