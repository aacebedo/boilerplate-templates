#!/usr/bin/env bash

#MISE description = "Re-apply the templates after editing the answers file"

#USAGE flag "-f --from-ref <ref>" help="Version the project was last rendered from (default: the committed answers)"

set -euo pipefail

# shellcheck source=static/mise/lib/templates.sh
. "$(dirname "$0")/../../lib/templates.sh"

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

	templates_from_ref="${usage_from_ref:-}"
	if ! templates_committed_answers >"$tmp/old-answers.yaml"; then
		if [ -z "$templates_from_ref" ]; then
			printf "\033[31m%s is not committed, so there is no applied state to update from.\033[0m\n" \
				"$templates_answers" >&2
			printf "\033[31mPass --from-ref <ref> to name the version it was rendered from.\033[0m\n" >&2
			exit 1
		fi
		cp "$templates_answers" "$tmp/old-answers.yaml"
	fi
	templates_plan "$tmp" || exit 1

	if templates_plan_is_empty "$tmp"; then
		printf "\033[31mHEAD already records %s with the same answers, so there is nothing to compare against.\033[0m\n" \
			"$templates_new_ref" >&2
		printf "\033[31mEdit %s and leave the change uncommitted, or pass %s to name the applied version.\033[0m\n" \
			"$templates_answers" "--from-ref <ref>" >&2
		exit 1
	fi

	printf '\033[37mRendering the templates at %s and %s\033[0m\n' "$templates_old_ref" "$templates_new_ref"
	templates_patch "$tmp"

	if [ ! -s "$tmp/update.patch" ]; then
		printf '\033[37mNothing to apply: the templates produce what the project already has.\033[0m\n'
		exit 0
	fi

	templates_filter_patch "$tmp"

	if [ -s "$tmp/skipped" ]; then
		printf "\033[33mLeaving alone what the project no longer tracks:\033[0m\n%s\n" \
			"$(sed 's/^/  /' "$tmp/skipped")" >&2
	fi

	if [ -z "$(templates_changed_files "$tmp")" ]; then
		printf '\033[37mNothing to apply: the templates produce what the project already has.\033[0m\n'
		write_answers "$tmp/manifest.yaml" "$templates_new_ref" >"$templates_answers"
		exit 0
	fi

	local status=0
	if [ -s "$tmp/filtered.patch" ]; then
		find "$tmp/old" -type f -exec git hash-object -w {} + >/dev/null
		if ! git apply -p2 --3way "$tmp/filtered.patch"; then
			if [ -z "$(git ls-files --unmerged)" ]; then
				printf "\033[31mCould not apply %s, so nothing was changed.\033[0m\n" "$templates_new_ref" >&2
				exit 1
			fi
			status=1
		fi
	fi
	merge_added "$tmp" || status=1
	apply_deleted "$tmp" || status=1

	write_answers "$tmp/manifest.yaml" "$templates_new_ref" >"$templates_answers"

	if [ "$status" -ne 0 ]; then
		printf "\033[31mApplying %s left conflicts to resolve:\033[0m\n%s\n" \
			"$templates_new_ref" "$(git ls-files --unmerged | cut -f2 | sort -u | sed 's/^/  /')" >&2
		exit 1
	fi
	printf '\033[37mApplied the templates at %s\033[0m\n' "$templates_new_ref"
}

stage_conflict() {
	local path="$1" mode=100644 stage=1 blob
	shift
	if [ -x "$path" ]; then
		mode=100755
	fi
	{
		printf '0 %040d\t%s\n' 0 "$path"
		for blob in "$@"; do
			if [ -n "$blob" ]; then
				printf '%s %s %d\t%s\n' "$mode" "$blob" "$stage" "$path"
			fi
			stage=$((stage + 1))
		done
	} | git update-index --index-info
}

merge_added() {
	local tmp="$1" path ours theirs status=0
	: >"$tmp/empty"
	while IFS= read -r path; do
		ours="$(git hash-object -w -- "$path")"
		theirs="$(git hash-object -w -- "$tmp/new/$path")"
		if git merge-file -L ours -L base -L theirs "$path" "$tmp/empty" "$tmp/new/$path"; then
			git add -- "$path"
		else
			printf "\033[33mThe templates now provide %s, which the project already has.\033[0m\n" "$path" >&2
			stage_conflict "$path" "" "$ours" "$theirs"
			status=1
		fi
	done <"$tmp/added"
	return "$status"
}

apply_deleted() {
	local tmp="$1" path status=0
	while IFS= read -r path; do
		if cmp -s "$path" "$tmp/old/$path"; then
			git rm -q -f --ignore-unmatch -- "$path"
			rm -f -- "$path"
		else
			printf "\033[33mThe templates no longer provide %s, which the project has changed.\033[0m\n" "$path" >&2
			stage_conflict "$path" "$(git hash-object -w -- "$tmp/old/$path")" "$(git hash-object -w -- "$path")" ""
			status=1
		fi
	done <"$tmp/deleted"
	return "$status"
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
