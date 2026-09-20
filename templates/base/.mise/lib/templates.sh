# shellcheck shell=bash

templates_answers=.boilerplate-answers.yaml

export GIT_TERMINAL_PROMPT=0

templates_load() {
	templates_url="$(yq -r '.template_url // ""' "$templates_answers")"
	if [ -z "$templates_url" ]; then
		printf "\033[31m%s records no template repository.\033[0m\n" "$templates_answers" >&2
		return 1
	fi
	templates_url="${templates_url#git::}"
}

templates_ref() {
	local ref
	ref="$(yq -r '.template_ref // ""' "$1")"
	if [ -z "$ref" ]; then
		printf "\033[33m%s records no template version.\033[0m\n" "$1" >&2
		return 1
	fi
	printf '%s\n' "$ref"
}

templates_vars() {
	yq 'del(.template_url, .template_ref)' "$1"
}

templates_render() {
	local ref="$1" out="$2" vars="$3"
	shift 3
	boilerplate --template-url "git::${templates_url}//templates/base?ref=${ref}" --output-folder "$out" \
		--var-file "$vars" --non-interactive --no-hooks "$@" >/dev/null
}

templates_committed_answers() {
	git show "HEAD:./$templates_answers" 2>/dev/null
}

templates_plan() {
	local tmp="$1"
	templates_old_ref="${templates_from_ref:-}"
	if [ -z "$templates_old_ref" ]; then
		templates_old_ref="$(templates_ref "$tmp/old-answers.yaml")" || return 1
	fi
	templates_new_ref="$(templates_ref "$templates_answers")" || return 1
	templates_vars "$tmp/old-answers.yaml" >"$tmp/old-vars.yaml"
	templates_vars "$templates_answers" >"$tmp/new-vars.yaml"
}

templates_plan_is_empty() {
	local tmp="$1"
	[ "$templates_old_ref" = "$templates_new_ref" ] &&
		cmp -s "$tmp/old-vars.yaml" "$tmp/new-vars.yaml"
}

templates_patch() {
	local tmp="$1"
	templates_render "$templates_old_ref" "$tmp/old" "$tmp/old-vars.yaml"
	templates_render "$templates_new_ref" "$tmp/new" "$tmp/new-vars.yaml" --manifest-file "$tmp/manifest.yaml"
	(cd "$tmp" && git diff --no-index --binary old new) >"$tmp/update.patch" || true
}

templates_filter_patch() {
	local tmp="$1"
	: >"$tmp/skipped"
	awk -v root="$PWD" -v skipped="$tmp/skipped" '
		function emit() {
			if (n > 0 && keep)
				for (i = 1; i <= n; i++) print buf[i]
			n = 0
		}
		function absent(p) {
			return system("test -e \"" root "/" p "\"") != 0
		}
		/^diff --git / {
			emit()
			keep = 1
			if ($0 !~ /"/) {
				src = $3
				dst = $4
				if (src ~ /^a\/old\//) {
					sub(/^a\/old\//, "", src)
					if (absent(src)) {
						keep = 0
						print src >skipped
					}
				} else {
					sub(/^b\/new\//, "", dst)
					if (!absent(dst)) {
						keep = 0
						print dst >skipped
					}
				}
			}
		}
		{ buf[++n] = $0 }
		END { emit() }
	' "$tmp/update.patch" >"$tmp/filtered.patch"
	if [ -s "$tmp/skipped" ]; then
		sort -u -o "$tmp/skipped" "$tmp/skipped"
	fi
}

templates_patch_files() {
	awk '/^diff --git / { p = $4; sub(/^b\/(new|old)\//, "", p); print p }' "$1" | sort -u
}
