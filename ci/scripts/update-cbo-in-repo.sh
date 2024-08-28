#!/usr/bin/env bash
#
# COPYRIGHT Ericsson 2022
#
#
#
# The copyright to the computer program(s) herein is the property of
#
# Ericsson Inc. The programs may be used and/or copied only with written
#
# permission from Ericsson Inc. or in accordance with the terms and
#
# conditions stipulated in the agreement/contract under which the
#
# program(s) have been supplied.
#

set -eux -o pipefail

WORKSPACE=$1
CBO_PRA_VERSION="$2"
EMAIL=$3
FILES_TO_UPDATE="$4"

FOSSA_DIR="config/fossa"

IFS=, read -ra filesToUpdate <<< "$FILES_TO_UPDATE"

repoName=$(basename $WORKSPACE)

echo "Updating CBOS version to ${CBO_PRA_VERSION} in $repoName"
cd $WORKSPACE

changedFiles=(rulesets/common-properties.yaml)

sed -i "s/common-base-os-version: .*/common-base-os-version: ${CBO_PRA_VERSION}/" rulesets/common-properties.yaml

CBO_SEMVER=$(echo ${CBO_PRA_VERSION} | sed 's/\(.*\)-.*/\1/')

for file in "${filesToUpdate[@]}"; do
    changedFiles+=("${FOSSA_DIR}/${file}")
    sed -i "/- name: Common Base OS$/{n;s/version: .*/version: ${CBO_SEMVER}/}" "${FOSSA_DIR}/${file}"
done 

gerrit create-patch --file ${changedFiles[*]} \
    --message "[NoJira] Update Common Base OS to ${CBO_PRA_VERSION}" \
    --git-repo-local . \
    --wait-label "Verified"="+1" \
    --debug \
    --email ${EMAIL} \
    --submit 

changeStatus=$? 

if [ $changeStatus -eq 0 ]; then
        echo "Change is merged successfully"
else
    echo "Change failed verification and could not be merged"
    exit 1
fi 