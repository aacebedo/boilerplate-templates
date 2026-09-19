#!/usr/bin/env bash

#MISE description = "Check that the applied boilerplate templates are up to date"

set -euo pipefail

. "${0%/.mise/tasks/*}/.mise/lib/task.sh"
# shellcheck source=.mise/lib/templates.sh
. "${0%/.mise/tasks/*}/.mise/lib/templates.sh"

answers=.boilerplate-answers.yaml

if [ ! -f "$answers" ]; then
	apply="boilerplate --output-folder . --template-url '${templates_url}?ref=<version>'"
	printf "\033[31mNo boilerplate template is applied - run '%s'.\033[0m\n" "$apply" >&2
	exit 1
fi

ref="$(yq -r '.template_ref // ""' "$answers")"
if [ -z "$ref" ]; then
	printf "\033[33mWarning: %s records no template version: skipping the check.\033[0m\n" "$answers" >&2
	exit 0
fi

tags="$(templates_tags)"
latest="${tags%%$'\n'*}"

# An application from a branch or a local checkout records a commit, which no release can
# be compared against.
if ! printf '%s\n' "$tags" | grep -qxF -- "$ref"; then
	printf "\033[33mWarning: the templates were applied from %s, which is no release tag:\n" "$ref" >&2
	printf "skipping the check.\033[0m\n" >&2
	exit 0
fi

if [ "$latest" != "$ref" ]; then
	printf "\033[31mThe templates are at %s but %s is available - run '%s'.\033[0m\n" \
		"$ref" "$latest" "mise run update-templates" >&2
	exit 1
fi
