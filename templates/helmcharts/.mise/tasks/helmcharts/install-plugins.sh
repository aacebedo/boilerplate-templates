#!/usr/bin/env bash

#MISE description = "Install the Helm plugins the chart tasks need"
#MISE hide = true
#MISE env.HELM_UNITTEST_VERSION = "{{`{{vars.helm_unittest_version}}`}}"

set -euo pipefail

. "${0%/.mise/tasks/*}/.mise/lib/task.sh"

installed="$(helm plugin list | awk '$1 == "unittest" { print $2 }')"
if [ "${installed}" != "${HELM_UNITTEST_VERSION}" ]; then
	[ -z "${installed}" ] || helm plugin uninstall unittest
	helm plugin install https://github.com/helm-unittest/helm-unittest --version "${HELM_UNITTEST_VERSION}" \
		--verify=false
fi
