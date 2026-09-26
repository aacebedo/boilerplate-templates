#!/usr/bin/env bash

#MISE description = "Remove the Python virtual environment and tool caches"
#MISE hide = true

set -euo pipefail

rm -rf .venv .pytest_cache .ruff_cache
