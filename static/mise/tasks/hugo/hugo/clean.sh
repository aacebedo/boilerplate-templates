#!/usr/bin/env bash

#MISE description = "Remove the Hugo build output and the npm tree the tests install"
#MISE hide = true

set -euo pipefail

rm -rf .build src/.hugo_build.lock tests/node_modules tests/package-lock.json src/hugo_stats.json
