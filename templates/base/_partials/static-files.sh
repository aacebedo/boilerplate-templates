#!/bin/sh

set -eu

project="$(cd "$1" && pwd -P)"
layers="$2"
kind="$3"
name="${4:-}"
root="$(git rev-parse --show-toplevel)"

remote_url() {
	remote="$(git -C "$1" remote | grep -x origin || git -C "$1" remote | head -n 1)"
	git -C "$1" remote get-url "$remote"
}

repo="$root"
case "$root" in
*/boilerplate-cache*)
	url="$(remote_url "$root")"
	url="${url#file://}"
	case "$url" in
	/* | .*) repo="$(cd "$project" && cd "$url" && pwd -P)" ;;
	esac
	;;
esac

self=false
if [ "$repo" = "$project" ]; then
	self=true
else
	url="$(remote_url "$repo")"
	case "$url" in
	git@*:*)
		url="${url#git@}"
		url="https://${url%%:*}/${url#*:}"
		;;
	esac
	ref="$(git -C "$root" describe --tags --exact-match HEAD 2>/dev/null || git -C "$root" rev-parse HEAD)"
fi

reference() {
	if [ "$self" = true ]; then
		printf 'static_files/%s' "$1"
	elif [ "$kind" = dprint ]; then
		path="${url#https://github.com/}"
		printf 'https://raw.githubusercontent.com/%s/%s/static_files/%s' "${path%.git}" "$ref" "$1"
	else
		printf 'git::%s//static_files/%s?ref=%s' "$url" "$1" "$ref"
	fi
}

case "$kind" in
mise)
	printf '[task_config]\nincludes = [\n'
	for layer in base $(printf '%s' "$layers" | tr , ' '); do
		printf '  "%s",\n' "$(reference "mise/tasks/$layer")"
	done
	printf '  ".mise/tasks",\n]\n'
	;;
dprint)
	for layer in $(printf '%s' "$layers" | tr , ' '); do
		[ ! -f "$root/static_files/dprint/$layer.json" ] || printf '"%s",\n' "$(reference "dprint/$layer.json")"
	done
	printf '"%s"\n' "$(reference dprint/base.json)"
	;;
github)
	if [ "$self" = true ]; then
		printf './.github/workflows/%s' "$name"
	else
		path="${url#https://github.com/}"
		printf '%s/.github/workflows/%s@%s' "${path%.git}" "$name" "$ref"
	fi
	;;
esac
