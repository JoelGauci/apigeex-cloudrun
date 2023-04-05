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
[ -z "$APIGEE_X_ORG" ] && printf "Apigee X Organization: "    && read -r APIGEE_X_ORG
[ -z "$APIGEE_X_ENV" ] && printf "Apigee X Environment: "    && read -r APIGEE_X_ENV
[ -z "$APIGEE_X_HOSTNAME" ] && printf "Apigee X Hostname: "    && read -r APIGEE_X_HOSTNAME

###
### destroy_common_gcp_resources()
###
destroy_common_gcp_resources() {

  terraform init
  terraform destroy --var-file="./input.tfvars" \
    -auto-approve
}

## 
###
### destroy_common_gcp_resources()
###
main() {
  cd ${SCRIPTPATH}
  destroy_common_gcp_resources
}

main "${@}"
