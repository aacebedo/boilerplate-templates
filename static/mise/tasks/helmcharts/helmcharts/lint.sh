#!/usr/bin/env bash

#MISE description = "Lint every chart under charts/"
#MISE hide = true

set -euo pipefail

shopt -s nullglob
charts=(charts/*/Chart.yaml)
[ "${#charts[@]}" -gt 0 ] || exit 0

helm lint "${charts[@]%/Chart.yaml}"
