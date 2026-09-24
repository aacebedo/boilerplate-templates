#!/usr/bin/env bash

#MISE description = "Package every chart under charts/ into .build/charts"

set -euo pipefail

shopt -s nullglob
charts=(charts/*/Chart.yaml)
[ "${#charts[@]}" -gt 0 ] || exit 0

mkdir -p .build/charts
for chart in "${charts[@]%/Chart.yaml}"; do
	[ ! -f "${chart}/Chart.lock" ] || helm dependency build "${chart}"
	helm package "${chart}" --destination .build/charts
done
