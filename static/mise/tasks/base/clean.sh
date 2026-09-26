#!/usr/bin/env bash

#MISE description = "Remove generated files, after running every template's <template>:clean task"

#MISE depends = [{ task = "*:clean", optional = true }]

set -euo pipefail

rm -rf .rumdl_cache
