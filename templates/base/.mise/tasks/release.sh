#!/usr/bin/env bash

#MISE description = "Publish a release by running every template's <template>:release task"
# Each applied template may ship its own <template>:release task (base:release always
# exists, so the pattern never matches nothing).
#MISE depends = ["*:release"]

set -euo pipefail

. "${0%/.mise/tasks/*}/.mise/lib/task.sh"
