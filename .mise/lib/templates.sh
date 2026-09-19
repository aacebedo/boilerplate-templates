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
	templates_old_ref="$(templates_ref "$tmp/old-answers.yaml")" || return 1
	templates_new_ref="$(templates_ref "$templates_answers")" || return 1
	templates_vars "$tmp/old-answers.yaml" >"$tmp/old-vars.yaml"
	templates_vars "$templates_answers" >"$tmp/new-vars.yaml"
}

templates_patch() {
	local tmp="$1"
	templates_render "$templates_old_ref" "$tmp/old" "$tmp/old-vars.yaml"
	templates_render "$templates_new_ref" "$tmp/new" "$tmp/new-vars.yaml" --manifest-file "$tmp/manifest.yaml"
	(cd "$tmp" && git diff --no-index --binary old new) >"$tmp/update.patch" || true
}
