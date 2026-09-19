#!/usr/bin/env bash

#MISE description = "Update the applied boilerplate templates to the latest release"

set -euo pipefail

. "${0%/.mise/tasks/*}/.mise/lib/task.sh"
# shellcheck source=.mise/lib/templates.sh
. "${0%/.mise/tasks/*}/.mise/lib/templates.sh"

# Boilerplate has no update command: render the version recorded in the answers file and
# the latest release with the recorded answers, then 3-way merge the difference into the
# project. The answers themselves never change here - edit them and re-apply the template
# to add or drop a layer.
# Everything runs from main so bash has parsed the whole file before the patch rewrites
# it: this script is itself one of the templated files.
main() {
	local answers=.boilerplate-answers.yaml
	if [ ! -f "$answers" ]; then
		printf "\033[31mNo boilerplate template is applied (%s is missing) - nothing to update.\033[0m\n" \
			"$answers" >&2
		exit 1
	fi

	local old_ref tags new_ref
	# The release tag the project was generated from, or the exact commit it was rendered
	# from when the templates were applied from a branch or a local checkout.
	old_ref="$(yq -r '.template_ref // ""' "$answers")"
	if [ -z "$old_ref" ]; then
		printf "\033[31m%s records no template version to update from.\033[0m\n" "$answers" >&2
		exit 1
	fi

	# Always the newest release, which is a tag by construction and so needs no resolving
	# before it is recorded.
	tags="$(templates_tags)"
	new_ref="${tags%%$'\n'*}"
	if [ "$old_ref" = "$new_ref" ]; then
		printf '\033[37mThe templates are already at %s.\033[0m\n' "$new_ref"
		exit 0
	fi

	local tmp
	tmp="$(mktemp -d)"
	# shellcheck disable=SC2064 # expand now: tmp is local to main.
	trap "rm -rf '$tmp'" EXIT

	# Everything but the bookkeeping key is a Boilerplate variable, and both renders get
	# the same ones, so the patch only carries what the templates themselves changed.
	yq 'del(.template_ref)' "$answers" >"$tmp/vars.yaml"

	printf '\033[37mRendering the templates at %s\033[0m\n' "$old_ref"
	render "$old_ref" "$tmp/old" "$tmp/vars.yaml"
	printf '\033[37mRendering the templates at %s\033[0m\n' "$new_ref"
	# The manifest is the only place Boilerplate reports the variables a render actually
	# used, including the defaults of questions the new version added, so harvest the new
	# answers from a throwaway one.
	render "$new_ref" "$tmp/new" "$tmp/vars.yaml" --manifest-file "$tmp/manifest.yaml"

	# git apply --3way needs the blobs the patch starts from.
	find "$tmp/old" -type f -exec git hash-object -w {} + >/dev/null

	local status=0
	(cd "$tmp" && git diff --no-index --binary old new) >"$tmp/update.patch" || true
	if [ -s "$tmp/update.patch" ]; then
		git apply -p2 --3way "$tmp/update.patch" || status=$?
	fi

	write_answers "$tmp/manifest.yaml" "$new_ref" >"$answers"

	if [ "$status" -ne 0 ]; then
		printf "\033[31mUpdating to %s left conflicts to resolve:\033[0m\n%s\n" \
			"$new_ref" "$(git diff --name-only --diff-filter=U)" >&2
		exit 1
	fi
	printf '\033[37mUpdated the templates to %s\033[0m\n' "$new_ref"
}

# Renders the templates at a version into a folder. The answers file is written by a hook,
# so --no-hooks keeps it out of both renders and out of the patch; it is rewritten from
# the manifest instead.
render() {
	local ref="$1" out="$2" vars="$3"
	shift 3
	boilerplate --template-url "${templates_url}?ref=${ref}" --output-folder "$out" \
		--var-file "$vars" --non-interactive --no-hooks "$@" >/dev/null
}

# Prints the answers file for a render: the variables its manifest reports, under the key
# recording the version they came from. Mirrors the after hook of the base template, which
# writes the same file when the templates are first applied.
write_answers() {
	local manifest="$1" ref="$2"
	printf '%s\n' \
		'# The answers the Boilerplate templates were applied with, and the template' \
		'# version they were rendered from. Rewritten by "mise run update-templates".' \
		'---'
	# The base variables merged with those of every layer, which also carry the inherited
	# base ones; __each__ is the layer's own name, set by for_each.
	# shellcheck disable=SC2016 # $v is a yq variable.
	REF="$ref" yq \
		'[.Variables] + [.Dependencies[] | .Variables // {}] | .[] as $v ireduce ({}; . * $v) |
		del(.__each__) | sort_keys(.) |
		{"template_ref": strenv(REF)} * .' \
		"$manifest"
}

main
