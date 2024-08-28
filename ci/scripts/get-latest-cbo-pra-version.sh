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

# Absolute filepath to this script
case "$(uname -s)" in
Darwin*) SCRIPT=$(greadlink -f $0) ;;
*) SCRIPT=$(readlink -f $0) ;;
esac

# Location of parent dir
BASE_DIR=$(dirname $SCRIPT)
REPOROOT=$(dirname $(dirname $BASE_DIR))

BOB_DIR=$REPOROOT/.bob

if [ -z "$API_TOKEN" ]; then
    echo "API_TOKEN is not set"
    exit 1
fi

if [ -z "$CI_USER"  ]; then
    echo "CI_USER is not set"
    exit 1
fi

CBO_PRA_DETAILS_FILE=$BOB_DIR/cbo-pra-details.json

curl -u"$CI_USER:$API_TOKEN" -X POST https://arm.epk.ericsson.se/artifactory/api/search/aql -H "content-type:text/plain" -d 'items.find({ "repo": {"$eq":"docker-v2-global-local"},"path":{"$match": "proj-ldc/common_base_os_release/*"}}).sort({"$desc": ["created"]}).limit(1)' 2>/dev/null > $CBO_PRA_DETAILS_FILE
aqlStatus=$?

if [ $aqlStatus -ne 0 ]; then
    echo "Failed to get latest CBO PRA version"
    exit 1
fi

if [ -f $CBO_PRA_DETAILS_FILE ]; then
    CBO_PRA_VERSION=$(cat $CBO_PRA_DETAILS_FILE | jq -r '.results[0].path' | sed 's#proj-ldc/common_base_os_release/sles/##')
    echo $CBO_PRA_VERSION | tee $BOB_DIR/var.latest-cbo-pra-version
else
    echo "Failed to get CBO PRA version"
    exit 1
fi