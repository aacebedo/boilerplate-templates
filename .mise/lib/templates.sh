# shellcheck shell=bash

# The templates only ever come from here, so the answers file records no URL: the version
# they were rendered at is all that varies.
templates_repo="https://github.com/aacebedo/boilerplate-templates"
# shellcheck disable=SC2034 # read by the scripts that source this library.
templates_url="git::${templates_repo}.git//templates/base"

# GitHub answers an unknown repository by asking for credentials, in case it is private
# and the caller has access. Nothing here can use them, and a task that blocks on a
# terminal prompt would hang a lint run or a CI job, so let git fail instead. This also
# covers the clones Boilerplate makes when rendering.
export GIT_TERMINAL_PROMPT=0

# Prints the repository's release tags, newest first, and fails with a message when it
# publishes none or cannot be reached. Releases carry a leading "v" or nothing at all, so
# both are listed and the prefix is stripped before the version sort, which would
# otherwise order the two families apart.
templates_tags() {
	local tags
	if ! tags="$(git ls-remote --tags --refs "$templates_repo" 'v[0-9]*' '[0-9]*' |
		awk '{ sub(/.*refs\/tags\//, ""); v = $0; sub(/^v/, "", v); print v "\t" $0 }' |
		sort -t"$(printf '\t')" -k1,1 -rV | cut -f2)"; then
		printf "\033[31mCould not read %s (see above).\n" "$templates_repo" >&2
		printf "It must exist and be readable without credentials to check for updates.\033[0m\n" >&2
		return 1
	fi
	if [ -z "$tags" ]; then
		printf "\033[31m%s publishes no release tag.\033[0m\n" "$templates_repo" >&2
		return 1
	fi
	printf '%s\n' "$tags"
}
