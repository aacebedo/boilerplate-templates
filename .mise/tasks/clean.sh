#!/usr/bin/env bash

#MISE description = "Remove generated files by running every template's <template>:clean task"
#MISE depends = ["*:clean"]

set -euo pipefail

. "${0%/.mise/tasks/*}/.mise/lib/task.sh"
