#!/usr/bin/env bash

#MISE description = "Publish a release with cog, after running every template's <template>:release task"

#MISE depends = ["lint", { task = "*:release", optional = true }]

#MISE env = { GITHUB_TOKEN = { required = true, redact = true } }

set -euo pipefail

cog bump --auto --skip-ci
