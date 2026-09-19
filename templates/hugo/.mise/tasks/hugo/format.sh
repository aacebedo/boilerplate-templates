#!/usr/bin/env bash

#MISE description = "Format the Hugo layouts"
#MISE hide = true

set -euo pipefail

. "${0%/.mise/tasks/*}/.mise/lib/task.sh"

djlint --reformat src/layouts
