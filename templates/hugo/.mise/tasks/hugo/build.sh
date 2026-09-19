#!/usr/bin/env bash

#MISE description = "Build the Hugo site"

set -euo pipefail

. "${0%/.mise/tasks/*}/.mise/lib/task.sh"

cd src
hugo mod get
hugo build
