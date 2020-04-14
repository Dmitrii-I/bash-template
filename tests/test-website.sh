#!/usr/bin/env bash

POSIXLY_CORRECT=1 set -o errexit && set -o nounset && set -o pipefail && unset POSIXLY_CORRECT

urls="https://www.bash-template.com
https://bash-template.com
http://www.bash-template.com
http://bash-template.com
bash-template.com
"

for url in $urls; do
    echo "Test that contents of $url are same as template.sh."

    echo "Get website with curl"
    diff <(curl --silent "$url") ~/bash-template/template.sh

    echo "Get website with wget"
    diff <(wget -O - "$url" -o /dev/null) ~/bash-template/template.sh

    echo "Get website with http"
    diff <(http --body GET "$url" 2>/dev/null) ~/bash-template/template.sh

done

