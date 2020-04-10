#!/usr/bin/env bash
# bash-template.com, version 1

set -o nounset
set -o errexit
set -o pipefail

on_error() {
    echo "Caught error on line $1"
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

