#!/usr/bin/env bash

#MISE description = "Remove the Rust build output"
#MISE hide = true

set -euo pipefail

rm -rf target
