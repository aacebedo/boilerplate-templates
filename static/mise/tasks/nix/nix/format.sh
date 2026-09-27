#!/usr/bin/env bash

#MISE description = "Format the Nix code"
#MISE hide = true

set -euo pipefail

alejandra --quiet .
