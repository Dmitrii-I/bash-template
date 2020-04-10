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

cd ~/bash-template/terraform
cloudfront_distribution_id="$(TF_CLI_CONFIG_FILE=~/.terraformrc-bash-template terraform output cloudfront_distribution_id)"

aws cloudwatch get-metric-statistics \
    --region us-east-1 \
    --profile bash-template-read-only \
    --start-time "$(date --utc --iso-8601 -d '-14 days')T00:00:00Z" \
    --end-time "$(date --utc --iso-8601 -d '+1 day')T00:00:00Z" \
    --namespace "AWS/CloudFront" \
    --statistics Sum \
    --period 3600 \
    --metric-name Requests \
    --dimensions Name=DistributionId,Value="$cloudfront_distribution_id" Name=Region,Value=Global \
    | jq '.Datapoints[] | [.Timestamp, .Sum] | @tsv' --raw-output \
    | sort

