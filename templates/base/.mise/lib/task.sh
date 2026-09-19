# shellcheck shell=bash

# Sourced by every task script. When the script was executed directly rather than
# through mise, re-run it as its task, so that its tools, environment, dependencies
# and usage flags are always in place. The task name is the script's path under
# .mise/tasks/, without the extension and with the directories as separators.
if [ -z "${MISE_TASK_NAME:-}" ]; then
	_mise_task="${0#*/.mise/tasks/}"
	_mise_task="${_mise_task%.sh}"
	cd "${0%/.mise/tasks/*}" || exit 1
	exec mise run "${_mise_task//\//:}" "$@"
fi
