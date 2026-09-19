#!/usr/bin/env bash

#MISE description = "Run every template's <template>:test task"
# Each applied template ships its own <template>:test task (base:test always
# exists, so the pattern never matches nothing).
#MISE depends = ["*:test"]

set -euo pipefail

. "${0%/.mise/tasks/*}/.mise/lib/task.sh"
