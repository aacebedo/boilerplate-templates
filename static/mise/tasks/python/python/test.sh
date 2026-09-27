#!/usr/bin/env bash

#MISE description = "Run the tests with pytest"
#MISE depends = ["python:build"]
#MISE hide = true

set -euo pipefail

status=0
uv run pytest || status=$?
if [ "$status" -eq 5 ]; then
	exit 0
fi
exit "$status"
