#!/usr/bin/env bash

#MISE description = "Bump pinned dependencies with Updatecli"

#MISE env = { UPDATECLI_GITHUB_TOKEN = { required = true, redact = true } }

#USAGE flag "-a --apply" help="Apply changes and open pull requests (default: dry run diff only)"

set -euo pipefail

. "${0%/.mise/tasks/*}/.mise/lib/task.sh"

command="diff"
if [ "${usage_apply:-false}" = "true" ]; then
	command=apply
fi

# Each template adds its own values file under .updatecli/values.d/ instead of
# editing values.yaml; updatecli merges them in order.
values=(--values .updatecli/values.yaml)
for file in .updatecli/values.d/*.yaml; do
	[ ! -f "$file" ] || values+=(--values "$file")
done

updatecli pipeline "${command}" --config .updatecli/manifests "${values[@]}"
