#!/usr/bin/env bash

#MISE description = "Build and test the crate with nextest"

#USAGE arg "[nextest_args]..." help="Extra arguments for cargo nextest run, e.g. -E 'test(name)' or --cargo-profile <p>"

set -euo pipefail

cargo nextest run --no-tests=warn "$@"
