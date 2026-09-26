#!/usr/bin/env bash

#MISE description = "Build the Hugo site"

set -euo pipefail

cd src
hugo mod get
hugo build
