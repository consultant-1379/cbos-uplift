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
VARIABLE_FILE=$2

 yq '.properties[]' "${WORKSPACE}/rulesets/common-properties.yaml" | yq '.common-base-os-version' > $VARIABLE_FILE