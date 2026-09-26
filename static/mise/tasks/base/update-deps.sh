#!/usr/bin/env bash

#MISE description = "Bump pinned dependencies with Updatecli"

#MISE env = { UPDATECLI_GITHUB_TOKEN = { required = true, redact = true } }

#USAGE flag "-a --apply" help="Apply changes and open pull requests (default: dry run diff only)"
#USAGE flag "--validate" help="Only validate the manifests"

set -euo pipefail

static="$(dirname "$0")/../../../updatecli"
UPDATE_TEMPLATES_TASK="$(realpath "$(dirname "$0")/update-templates.sh")"
export UPDATE_TEMPLATES_TASK

command=(pipeline diff)
if [ "${usage_validate:-false}" = "true" ]; then
	command=(manifest validate --experimental)
elif [ "${usage_apply:-false}" = "true" ]; then
	command=(pipeline apply)
fi

layers=(base)
if [ -f .boilerplate-answers.yaml ]; then
	IFS=, read -r -a extra <<<"$(yq -r '.layers // ""' .boilerplate-answers.yaml)"
	layers+=("${extra[@]}")
fi

configs=()
values=()
for layer in "${layers[@]}"; do
	[ ! -d "$static/$layer/manifests" ] || configs+=(--config "$static/$layer/manifests")
	[ ! -f "$static/$layer/values.yaml" ] || values+=(--values "$static/$layer/values.yaml")
done
[ ! -d .updatecli/manifests ] || configs+=(--config .updatecli/manifests)
[ ! -f .updatecli/values.yaml ] || values+=(--values .updatecli/values.yaml)
for file in .updatecli/values.d/*.yaml; do
	[ ! -f "$file" ] || values+=(--values "$file")
done

updatecli "${command[@]}" "${configs[@]}" "${values[@]}"
