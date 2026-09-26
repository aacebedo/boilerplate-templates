#!/usr/bin/env bash

#MISE description = "Format the Hugo layouts"
#MISE hide = true

set -euo pipefail

djlint --reformat src/layouts
