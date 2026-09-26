#!/usr/bin/env bash

#MISE description = "Format the Rust code"
#MISE hide = true

set -euo pipefail

cargo fmt
