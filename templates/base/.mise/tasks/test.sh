#!/usr/bin/env bash

#MISE description = "Run every template's <template>:test task"

#MISE depends = ["*:test"]

set -euo pipefail

. "${0%/.mise/tasks/*}/.mise/lib/task.sh"
