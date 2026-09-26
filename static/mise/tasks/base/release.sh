#!/usr/bin/env bash

#MISE description = "Publish a release with cog when a bumping commit changed a path listed in .release-paths"

#MISE depends = ["lint", { task = "*:release", optional = true }]

#MISE env = { GITHUB_TOKEN = { required = true, redact = true } }

set -euo pipefail

paths=()
if [ -f .release-paths ]; then
	mapfile -t paths < <(grep -vE '^[[:space:]]*(#|$)' .release-paths || true)
fi
if [ "${#paths[@]}" -eq 0 ]; then
	printf '\033[37mNothing to release: .release-paths lists no path.\033[0m\n'
	exit 0
fi

prefix="$(yq -p toml -r '.tag_prefix // ""' cog.toml)"
last="$(git describe --tags --abbrev=0 --match "${prefix}*" 2>/dev/null || true)"
range="HEAD"
[ -z "$last" ] || range="$last..HEAD"

subjects="$(git log --format=%s "$range" -- "${paths[@]}")"
if [ -z "$subjects" ]; then
	printf '\033[37mNothing to release: no commit since %s changed %s.\033[0m\n' "${last:-the first commit}" "${paths[*]}"
	exit 0
fi

types="$(yq -p toml -r '["feat", "fix"] + (.commit_types // {} | to_entries |
	map(select(.value.bump_major or .value.bump_minor or .value.bump_patch) | .key)) | unique | join("|")' cog.toml)"
if ! grep -qE "^((${types})(\([^)]*\))?!?|[a-z]+(\([^)]*\))?!): " <<<"$subjects"; then
	printf '\033[37mNothing to release: no commit changing %s bumps the version.\033[0m\n' "${paths[*]}"
	exit 0
fi

cog bump --auto --skip-ci
