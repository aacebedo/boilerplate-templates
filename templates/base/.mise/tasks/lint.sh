#!/usr/bin/env bash

#MISE description = "Apply linters"

set -euo pipefail

. "${0%/.mise/tasks/*}/.mise/lib/task.sh"

prek run --all-files
