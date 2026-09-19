#!/usr/bin/env bash

#MISE description = "Build and test the Hugo site"
#MISE hide = true
#MISE depends = ["hugo:run:tests"]

set -euo pipefail

. "${0%/.mise/tasks/*}/.mise/lib/task.sh"
