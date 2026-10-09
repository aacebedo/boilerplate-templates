#!/usr/bin/env bash

#MISE description = "Check whether applying the templates would change the project"

set -euo pipefail

# shellcheck source=static/mise/lib/templates.sh
. "$(dirname "$0")/../../lib/templates.sh"

main() {
	if [ ! -f "$templates_answers" ]; then
		apply="boilerplate --output-folder ."
		apply+=" --template-url 'git::https://github.com/aacebedo/boilerplate-templates.git//templates/base?ref=<version>'"
		printf "\033[31mNo boilerplate template is applied - run '%s'.\033[0m\n" "$apply" >&2
		exit 1
	fi

	templates_load

	local tmp
	tmp="$(mktemp -d)"
	# shellcheck disable=SC2064 # expand now: tmp is local to main.
	trap "rm -rf '$tmp'" EXIT

	templates_committed_answers >"$tmp/old-answers.yaml" || exit 0
	templates_plan "$tmp" || exit 0
	templates_patch "$tmp"
	templates_filter_patch "$tmp"

	local changed
	changed="$(templates_changed_files "$tmp" | pending "$tmp")"
	if [ -z "$changed" ]; then
		exit 0
	fi

	printf "\033[31mApplying the templates would change the project - run '%s':\033[0m\n" "mise run update-templates" >&2
	printf '%s\n' "$changed" | sed 's|^|  |' >&2
	exit 1
}

pending() {
	local tmp="$1" path base
	: >"$tmp/empty"
	while IFS= read -r path; do
		if [ ! -f "$path" ] || [ ! -f "$tmp/new/$path" ]; then
			printf '%s\n' "$path"
			continue
		fi
		base="$tmp/old/$path"
		if [ ! -f "$base" ]; then
			base="$tmp/empty"
		fi
		git merge-file -p --ours "$path" "$base" "$tmp/new/$path" >"$tmp/merged" 2>/dev/null || true
		if ! cmp -s "$tmp/merged" "$path"; then
			printf '%s\n' "$path"
		fi
	done
}

main
