#!/usr/bin/env bash

#MISE description = "Build and test the crate"
#MISE hide = true
#MISE depends = ["build"]

set -euo pipefail

. "${0%/.mise/tasks/*}/.mise/lib/task.sh"

cargo test
