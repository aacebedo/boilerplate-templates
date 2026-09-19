#!/usr/bin/env bash

#MISE description = "Nothing to test for the base template"
#MISE hide = true
# Only here so that the test task's *:test pattern always matches.

set -euo pipefail

. "${0%/.mise/tasks/*}/.mise/lib/task.sh"
