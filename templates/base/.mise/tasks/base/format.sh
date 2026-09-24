#!/usr/bin/env bash

#MISE description = "Format the files the base template's tools cover"
#MISE hide = true

set -euo pipefail

. "${0%/.mise/tasks/*}/.mise/lib/task.sh"

dprint fmt --config-discovery=ignore-descendants
prek run shfmt --all-files
