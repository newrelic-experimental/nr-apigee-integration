#!/bin/bash

# Function to create a property set
create() {
  TOKEN=$(gcloud auth print-access-token)
  ORG=${APIGEE_ORG:-"default here if not set as an env variable"}
  ENV=${APIGEE_ENV:-"default here if not set as an env variable"}
  NAME=NewRelicPropSet

  curl -X POST "https://apigee.googleapis.com/v1/organizations/$ORG/environments/$ENV/resourcefiles?name=$NAME&type=properties" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-type: multipart/form-data" \
    -F file=@newrelic.properties
}

# Function to read a property set
read() {
  TOKEN=$(gcloud auth print-access-token)
  ORG=${APIGEE_ORG:-"default here if not set as an env variable"}
  ENV=${APIGEE_ENV:-"default here if not set as an env variable"}
  NAME=NewRelicPropSet

  curl -X GET "https://apigee.googleapis.com/v1/organizations/$ORG/environments/$ENV/resourcefiles/properties/$NAME" \
    -H "Authorization: Bearer $TOKEN"
}

# Function to update a property set
update() {
  TOKEN=$(gcloud auth print-access-token)
  ORG=${APIGEE_ORG:-"default here if not set as an env variable"}
  ENV=${APIGEE_ENV:-"default here if not set as an env variable"}
  NAME=NewRelicPropSet

  curl -X PUT "https://apigee.googleapis.com/v1/organizations/$ORG/environments/$ENV/resourcefiles/properties/$NAME" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-type: multipart/form-data" \
    -F file=@newrelic.properties
}

# Function to delete a property set
delete() {
  TOKEN=$(gcloud auth print-access-token)
  ORG=${APIGEE_ORG:-"default here if not set as an env variable"}
  ENV=${APIGEE_ENV:-"default here if not set as an env variable"}
  NAME=NewRelicPropSet

  curl -X DELETE "https://apigee.googleapis.com/v1/organizations/$ORG/environments/$ENV/resourcefiles/properties/$NAME" \
    -H "Authorization: Bearer $TOKEN"
}

# Parse command-line arguments
while getopts "c:g:u:d:" opt; do
  case ${opt} in
    c )
      create
      ;;
    r )
      read
      ;;
    u )
      update
      ;;
    d )
      delete
      ;;
    \? )
      echo "Usage: cmd [-c] [-r] [-u] [-d]"
      ;;
  esac
done