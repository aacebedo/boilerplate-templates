#!/usr/bin/env bash

#MISE description = "Measure the test coverage of the crate"

#USAGE arg "[llvm_cov_args]..." help="Extra arguments for cargo llvm-cov nextest, e.g. --html or --cargo-profile <p>"

set -euo pipefail

cargo llvm-cov nextest --no-tests=warn "$@"
