#!/usr/bin/env bash

#MISE description = "Format the files the base template's tools cover"
#MISE hide = true

set -euo pipefail

. "${0%/.mise/tasks/*}/.mise/lib/task.sh"

biome format --write .
tombi format
yamlfmt
rumdl fmt .
prek run shfmt --all-files
