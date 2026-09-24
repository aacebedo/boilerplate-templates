#!/usr/bin/env bash

#MISE description = "Create the virtual environment and install the project's dependencies"

set -euo pipefail

uv sync
