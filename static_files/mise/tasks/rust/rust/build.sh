#!/usr/bin/env bash

#MISE description = "Build the crate"

set -euo pipefail

cargo build --all-targets
