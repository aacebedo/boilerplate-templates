#!/usr/bin/env bash

#MISE description = "Build and test the crate"
#MISE hide = true

#MISE depends = ["rust:build"]

set -euo pipefail

cargo test
