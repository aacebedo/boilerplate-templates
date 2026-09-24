#!/usr/bin/env bash

#MISE description = "Scan the built container image"
#MISE depends = ["container:build"]
#MISE wait_for = ["lint"]
#MISE env.COMMIT_SHA = "{{vars.commit_sha}}"

set -euo pipefail

image_tar="$(mktemp)"
trap 'rm -f "${image_tar}"' EXIT
podman save "${IMAGE_NAME}:${COMMIT_SHA}" -o "${image_tar}"

trivy image --input "${image_tar}" --ignorefile .trivyignore --severity HIGH,CRITICAL --exit-code 1 \
	--skip-version-check
