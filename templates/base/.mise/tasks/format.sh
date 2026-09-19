#!/usr/bin/env bash

#MISE description = "Format all code by running every template's <template>:format task"
# Each applied template ships its own <template>:format task (base:format always
# exists, so the pattern never matches nothing).
#MISE depends = ["*:format"]

set -euo pipefail

. "${0%/.mise/tasks/*}/.mise/lib/task.sh"
