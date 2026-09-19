#!/usr/bin/env bash

#MISE description = "Run the tests with pytest"
#MISE depends = ["python:build"]

set -euo pipefail

. "${0%/.mise/tasks/*}/.mise/lib/task.sh"

# pytest exits 5 when it collects no tests, which is where a new project starts.
status=0
uv run pytest || status=$?
if [ "$status" -eq 5 ]; then
	exit 0
fi
exit "$status"
