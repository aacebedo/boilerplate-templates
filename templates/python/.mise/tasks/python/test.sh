#!/usr/bin/env bash

#MISE description = "Build and test the Python project"
#MISE hide = true
#MISE depends = ["python:run:tests"]

set -euo pipefail

. "${0%/.mise/tasks/*}/.mise/lib/task.sh"
