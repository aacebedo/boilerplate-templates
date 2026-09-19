#!/usr/bin/env bash

#MISE description = "Format the Dockerfile"
#MISE hide = true

set -euo pipefail

. "${0%/.mise/tasks/*}/.mise/lib/task.sh"

[ ! -f src/Dockerfile ] || dockerfmt --write --newline src/Dockerfile
