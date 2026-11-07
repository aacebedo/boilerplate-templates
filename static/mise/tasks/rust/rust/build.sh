#!/usr/bin/env bash

#MISE description = "Build the crate"

#USAGE arg "[cargo_args]..." help="Extra arguments for cargo build, e.g. --release or --target <triple>"

set -euo pipefail

cargo build --all-targets "$@"
