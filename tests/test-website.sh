#!/usr/bin/env bash

set -o nounset      # exit with non-zero status if expansion is attempted on an unset variable
set -o errexit      # exit immediatelly if a pipeline, a list, or a compound command fails
set -o pipefail     # failures in pipe in the commands before last one, also count as failures

# Trapping non-zero exit codes:
on_error() {
    line_num="$1"
    echo "Caught error on line $line_num"
}

on_exit() {
    true
}

on_interrupt() {
    true
}
trap 'on_error $LINENO' ERR
trap on_exit EXIT
trap on_interrupt INT



urls="https://www.bash-template.com
https://bash-template.com
http://www.bash-template.com
http://bash-template.com
bash-template.com
"

for url in $urls; do
    echo "Test that contents of $url are same as template.sh."

    echo "Get website with curl"
    diff <(curl --silent $url) ~/bash-template/template.sh

    echo "Get website with wget"
    diff <(wget -O - http://www.bash-template.com -o /dev/null) ~/bash-template/template.sh

    echo "Get website with http"
    diff <(http --body http://www.bash-template.com 2>/dev/null) ~/bash-template/template.sh

done

