#!/usr/bin/env bash

#MISE description = "Build and smoke-test the site with a local server"
#MISE depends = ["hugo:build"]
#MISE hide = true

set -euo pipefail

test_files="$(dirname "$0")/test_files"
runner=.build/lighthouse-runner
mkdir -p "$runner"
cp "$test_files/package.json" "$test_files/lighthouse-check.mjs" "$runner/"
npm --prefix "$runner" install

caddyfile="$(mktemp)"
cat >"$caddyfile" <<EOF
:8080 {
	root * ${PWD}/.build/site
	encode gzip zstd
	file_server
}
EOF

caddy run --config "$caddyfile" --adapter caddyfile &
CADDY_PID=$!
trap 'kill "${CADDY_PID}" 2>/dev/null || true; rm -f "${caddyfile}"' EXIT

curl --retry 5 --retry-delay 5 --retry-all-errors --fail localhost:8080 >/dev/null

node "$runner/lighthouse-check.mjs" http://localhost:8080 90 .build/lighthouse
