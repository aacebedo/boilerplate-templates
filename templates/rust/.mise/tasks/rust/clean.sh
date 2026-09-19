#!/usr/bin/env bash

#MISE description = "Remove the Rust build output"
#MISE hide = true

set -euo pipefail

. "${0%/.mise/tasks/*}/.mise/lib/task.sh"

rm -rf target
