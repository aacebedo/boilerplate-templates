#!/usr/bin/env bash

#MISE description = "Evaluate the flake and run its checks"
#MISE hide = true

set -euo pipefail

if [ ! -f flake.nix ]; then
	exit 0
fi
if ! command -v nix >/dev/null; then
	printf '\033[33mSkipping the flake checks: nix is not installed.\033[0m\n' >&2
	exit 0
fi

nix flake check --no-build
