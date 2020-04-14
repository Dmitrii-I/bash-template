#!/usr/bin/env bash

POSIXLY_CORRECT=1 set -o errexit && set -o nounset && set -o pipefail && unset POSIXLY_CORRECT

echo Test shell scripts with shellcheck
find ~/bash-template -iname '*.sh' -exec shellcheck {} \;
echo PASSED
