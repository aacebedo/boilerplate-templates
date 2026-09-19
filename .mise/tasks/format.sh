#!/usr/bin/env bash

#MISE description = "Format all code by running every template's <template>:format task"

#MISE depends = ["*:format"]

set -euo pipefail

. "${0%/.mise/tasks/*}/.mise/lib/task.sh"
