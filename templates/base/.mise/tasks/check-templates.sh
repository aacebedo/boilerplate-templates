#!/usr/bin/env bash

#MISE description = "Check whether applying the templates would change the project"

set -euo pipefail

. "${0%/.mise/tasks/*}/.mise/lib/task.sh"
# shellcheck source=.mise/lib/templates.sh
. "${0%/.mise/tasks/*}/.mise/lib/templates.sh"

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

	if [ ! -s "$tmp/update.patch" ]; then
		exit 0
	fi

	printf "\033[31mApplying the templates would change the project - run '%s':\033[0m\n" "mise run update-templates" >&2
	(cd "$tmp" && git diff --no-index --name-only old new) | sed 's|^new/|  |' >&2
	exit 1
}

main
