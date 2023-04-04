#!/bin/sh
# Copyright 2023 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e

SCRIPTPATH="$( cd "$(dirname "$0")" || exit >/dev/null 2>&1 ; pwd -P )"

# Ask for input parameters if they are not set

[ -z "$GCP_PROJECT_ID" ]     && printf "GCP project id: "    && read -r GCP_PROJECT_ID
[ -z "$GCP_REGION" ]   && printf "GCP region: " && read -r GCP_REGION
[ -z "$GCP_ZONE" ]     && printf "GCP zone: "  && read -r GCP_ZONE
[ -z "$REPOSITORY_ID" ] && printf "Repository id: "    && read -r REPOSITORY_ID
[ -z "$CONSUMER_NETWORK" ] && printf "Consumer VPC: "    && read -r CONSUMER_NETWORK
[ -z "$APIGEE_X_ENV" ] && printf "Apigee X Environment: "    && read -r APIGEE_X_ENV
[ -z "$APIGEE_X_HOSTNAME" ] && printf "Apigee X Hostname: "    && read -r APIGEE_X_HOSTNAME

###
### create_artifact_registry()
###
create_artifact_registry() {

cd ${SCRIPTPATH}/terraform/artifact-registry

terraform init
terraform apply -var "gcp_project_id=${GCP_PROJECT_ID}" \
      -var "gcp_region=${GCP_REGION}" \
      -var "gcp_zone=${GCP_ZONE}" \
      -var "repository_id=${REPOSITORY_ID}" \
      -auto-approve
}

###
### create_push_app_images()
###
create_push_app_images() {

  cd ${SCRIPTPATH}/services/${1}
  gcloud builds submit --tag ${GCP_REGION}-docker.pkg.dev/${GCP_PROJECT_ID}/${REPOSITORY_ID}/${1}

  cd ${SCRIPTPATH}/services/${2}
  gcloud builds submit --tag ${GCP_REGION}-docker.pkg.dev/${GCP_PROJECT_ID}/${REPOSITORY_ID}/${2}

  cd ${SCRIPTPATH}/services/${3}
  gcloud builds submit --tag ${GCP_REGION}-docker.pkg.dev/${GCP_PROJECT_ID}/${REPOSITORY_ID}/${3}

}

###
### create_common_gcp_resources()
###
create_common_gcp_resources() {

  cd ${SCRIPTPATH}/terraform/common

  terraform init
  terraform apply -var "gcp_project_id=${GCP_PROJECT_ID}" \
        -var "gcp_region=${GCP_REGION}" \
        -var "gcp_zone=${GCP_ZONE}" \
        -var "repository_id=${REPOSITORY_ID}" \
        -var "url_mask=${1}" \
        -var "apigee_endpoint_attachment=${2}" \
        -auto-approve
}

###
### create_dns_resources()
###
create_dns_resources() {

  cd ${SCRIPTPATH}/terraform/dns

  terraform init
  terraform apply -var "gcp_project_id=${GCP_PROJECT_ID}" \
        -var "gcp_region=${GCP_REGION}" \
        -var "gcp_zone=${GCP_ZONE}" \
        -var "consumer_vpc=${CONSUMER_NETWORK}" \
        -var "endpoint_attachment_ipaddress=${1}" \
        -auto-approve
}

## 
###
### create_common_gcp_resources()
###
main() {
  create_artifact_registry
  create_push_app_images "login" "search" "translate"
  create_common_gcp_resources "/<service>" "pscendpoint"
  # Cloud Run app url
  APP_URL=$(terraform output -json service_urls | jq -r '.[0]')
  # psc endpoint host on apigee
  INSTANCE_ENDPOINT_HOST=$(terraform output -raw instance_endpoint_host)
  create_dns_resources ${INSTANCE_ENDPOINT_HOST}

  cd "$SCRIPTPATH";

  # dynamic set of the audience
  CLOUDRUN_APP_SUFFIX=$(echo "${APP_URL}" | sed "s/https:\/\/login//")
  export CLOUDRUN_APP_SUFFIX
  envsubst < "$SCRIPTPATH"/templates/AM-SetAudience.template.xml > "$SCRIPTPATH"/cloudrun-api-v1/apiproxy/policies/AM-SetAudience.xml

  # deploy the Apigee api proxy
  APIGEE_TOKEN="$(gcloud config config-helper --force-auth-refresh --format json | jq -r '.credential.access_token')"
  SA_EMAIL="apigee-apiproxy@$GCP_PROJECT_ID.iam.gserviceaccount.com"
  sackmesser deploy --googleapi \
    -o "$GCP_PROJECT_ID" \
    -e "$APIGEE_X_ENV" \
    -t "$APIGEE_TOKEN" \
    -h "$APIGEE_X_HOSTNAME" \
    -d "$SCRIPTPATH"/cloudrun-api-v1 \
    --deployment-sa "$SA_EMAIL"
}

main "${@}"