#!/usr/bin/env bash

#MISE description = "Remove the rumdl cache"
#MISE hide = true

set -euo pipefail

. "${0%/.mise/tasks/*}/.mise/lib/task.sh"

rm -rf .rumdl_cache
