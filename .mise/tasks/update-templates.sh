#!/usr/bin/env bash

#MISE description = "Re-apply the templates after editing the answers file"

set -euo pipefail

. "${0%/.mise/tasks/*}/.mise/lib/task.sh"
# shellcheck source=.mise/lib/templates.sh
. "${0%/.mise/tasks/*}/.mise/lib/templates.sh"

main() {
	if [ ! -f "$templates_answers" ]; then
		printf "\033[31mNo boilerplate template is applied (%s is missing) - nothing to update.\033[0m\n" \
			"$templates_answers" >&2
		exit 1
	fi
	templates_load

	local tmp
	tmp="$(mktemp -d)"
	# shellcheck disable=SC2064 # expand now: tmp is local to main.
	trap "rm -rf '$tmp'" EXIT

	if ! templates_committed_answers >"$tmp/old-answers.yaml"; then
		printf "\033[31m%s is not committed, so there is no applied state to update from.\033[0m\n" "$templates_answers" >&2
		exit 1
	fi
	templates_plan "$tmp" || exit 1

	printf '\033[37mRendering the templates at %s and %s\033[0m\n' "$templates_old_ref" "$templates_new_ref"
	templates_patch "$tmp"

	if [ ! -s "$tmp/update.patch" ]; then
		printf '\033[37mNothing to apply: the templates produce what the project already has.\033[0m\n'
		exit 0
	fi

	find "$tmp/old" -type f -exec git hash-object -w {} + >/dev/null

	local status=0
	git apply -p2 --3way "$tmp/update.patch" || status=$?

	write_answers "$tmp/manifest.yaml" "$templates_new_ref" >"$templates_answers"

	if [ "$status" -ne 0 ]; then
		printf "\033[31mApplying %s left conflicts to resolve:\033[0m\n%s\n" \
			"$templates_new_ref" "$(git diff --name-only --diff-filter=U)" >&2
		exit 1
	fi
	printf '\033[37mApplied the templates at %s\033[0m\n' "$templates_new_ref"
}

write_answers() {
	local manifest="$1" ref="$2"
	printf '%s\n' \
		'# The answers the Boilerplate templates were applied with, and the template' \
		'# version they were rendered from. Rewritten by "mise run update-templates".' \
		'---'
	# shellcheck disable=SC2016 # $v is a yq variable.
	URL="$templates_url" REF="$ref" yq \
		'[.Variables] + [.Dependencies[] | .Variables // {}] | .[] as $v ireduce ({}; . * $v) | sort_keys(.) |
		{"template_url": strenv(URL), "template_ref": strenv(REF)} * .' "$manifest"
}

main
