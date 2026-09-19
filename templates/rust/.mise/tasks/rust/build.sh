#!/usr/bin/env bash

#MISE description = "Build the crate"

set -euo pipefail

. "${0%/.mise/tasks/*}/.mise/lib/task.sh"

cargo build --all-targets
