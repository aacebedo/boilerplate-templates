#!/usr/bin/env bash

#MISE description = "Publish a release with cog when a bumping commit changed a path listed in .config/release-paths"

#MISE depends = ["lint", { task = "*:release", optional = true }]

#MISE env = { GITHUB_TOKEN = { required = true, redact = true } }

set -euo pipefail

release_paths=.config/release-paths
cog_config=.config/cog.toml

paths=()
if [ -f "$release_paths" ]; then
	mapfile -t paths < <(grep -vE '^[[:space:]]*(#|$)' "$release_paths" || true)
fi
if [ "${#paths[@]}" -eq 0 ]; then
	printf '\033[37mNothing to release: %s lists no path.\033[0m\n' "$release_paths"
	exit 0
fi

prefix="$(yq -p toml -r '.tag_prefix // ""' "$cog_config")"
last="$(git describe --tags --abbrev=0 --match "${prefix}*" 2>/dev/null || true)"
range="HEAD"
[ -z "$last" ] || range="$last..HEAD"

subjects="$(git log --format=%s "$range" -- "${paths[@]}")"
if [ -z "$subjects" ]; then
	printf '\033[37mNothing to release: no commit since %s changed %s.\033[0m\n' "${last:-the first commit}" "${paths[*]}"
	exit 0
fi

types="$(yq -p toml -r '["feat", "fix"] + (.commit_types // {} | to_entries |
	map(select(.value.bump_major or .value.bump_minor or .value.bump_patch) | .key)) | unique | join("|")' "$cog_config")"
if ! grep -qE "^((${types})(\([^)]*\))?!?|[a-z]+(\([^)]*\))?!): " <<<"$subjects"; then
	printf '\033[37mNothing to release: no commit changing %s bumps the version.\033[0m\n' "${paths[*]}"
	exit 0
fi

cog --config "$cog_config" bump --auto --skip-ci
