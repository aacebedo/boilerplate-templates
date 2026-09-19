#!/usr/bin/env bash

#MISE description = "Format the Rust code"
#MISE hide = true

set -euo pipefail

. "${0%/.mise/tasks/*}/.mise/lib/task.sh"

cargo fmt
