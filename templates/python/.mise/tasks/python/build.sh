#!/usr/bin/env bash

#MISE description = "Create the virtual environment and install the project's dependencies"

set -euo pipefail

. "${0%/.mise/tasks/*}/.mise/lib/task.sh"

uv sync
