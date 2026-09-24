#!/usr/bin/env bash

#MISE description = "Format all code, after running every template's <template>:format task"

#MISE depends = [{ task = "*:format", optional = true }]

set -euo pipefail

dprint fmt --config-discovery=ignore-descendants
prek run shfmt --all-files
