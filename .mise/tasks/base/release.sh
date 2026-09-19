#!/usr/bin/env bash

#MISE description = "Bump the version with cog and publish a GitHub release"
#MISE hide = true

#MISE depends = ["lint"]

#MISE env = { GITHUB_TOKEN = { required = true, redact = true } }

set -euo pipefail

. "${0%/.mise/tasks/*}/.mise/lib/task.sh"

cog bump --auto --skip-ci
