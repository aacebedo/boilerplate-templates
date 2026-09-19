#!/usr/bin/env bash

#MISE description = "Remove generated files by running every template's <template>:clean task"
# Each applied template ships its own <template>:clean task (base:clean always
# exists, so the pattern never matches nothing).
#MISE depends = ["*:clean"]

set -euo pipefail

. "${0%/.mise/tasks/*}/.mise/lib/task.sh"
