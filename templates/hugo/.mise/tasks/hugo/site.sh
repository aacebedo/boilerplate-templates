#!/usr/bin/env bash

#MISE description = "Serve the site locally"
#MISE depends = ["hugo:build"]

set -euo pipefail

. "${0%/.mise/tasks/*}/.mise/lib/task.sh"

cd src
hugo server --bind 0.0.0.0 --port 8080
