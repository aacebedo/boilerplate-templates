#!/usr/bin/env bash

#MISE description = "Remove the packaged charts and the fetched chart dependencies"
#MISE hide = true

set -euo pipefail

. "${0%/.mise/tasks/*}/.mise/lib/task.sh"

rm -rf .build/charts charts/*/charts
