# shellcheck shell=bash

if [ -z "${MISE_TASK_NAME:-}" ]; then
	_mise_task="${0#*/.mise/tasks/}"
	_mise_task="${_mise_task%.sh}"
	_mise_task="${_mise_task//\//:}"
	if ! command -v mise >/dev/null 2>&1; then
		printf "\033[31m%s is a mise task and cannot run on its own: install mise, then run '%s'.\033[0m\n" \
			"$0" "mise run $_mise_task" >&2
		exit 1
	fi
	if ! cd "${0%/.mise/tasks/*}"; then
		printf "\033[31m%s is a mise task and cannot run on its own: run '%s' from the project root.\033[0m\n" \
			"$0" "mise run $_mise_task" >&2
		exit 1
	fi
	exec mise run "$_mise_task" "$@"
fi
