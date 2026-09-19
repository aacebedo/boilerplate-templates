#!/usr/bin/env bash

#MISE description = "Run the helm-unittest suites of every chart under charts/"
#MISE depends = ["helmcharts:install-plugins"]

set -euo pipefail

. "${0%/.mise/tasks/*}/.mise/lib/task.sh"

shopt -s nullglob
charts=(charts/*/Chart.yaml)
[ "${#charts[@]}" -gt 0 ] || exit 0

helm unittest "${charts[@]%/Chart.yaml}"
