#!/usr/bin/env bash

#MISE description = "Publish a release by running every template's <template>:release task"

#MISE depends = ["*:release"]

set -euo pipefail

. "${0%/.mise/tasks/*}/.mise/lib/task.sh"
