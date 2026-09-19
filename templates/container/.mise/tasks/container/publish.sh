#!/usr/bin/env bash

#MISE description = "Publish the build image"
#MISE depends = ["container:build"]
#MISE env.IMAGE_NAME = "{{`{{vars.image_name}}`}}"
#MISE env.COMMIT_SHA = "{{`{{vars.commit_sha}}`}}"
#MISE env.REGISTRY_USERNAME = { required = true }
#MISE env.REGISTRY_PASSWORD = { required = true, redact = true }

set -euo pipefail

. "${0%/.mise/tasks/*}/.mise/lib/task.sh"

version="${1:?usage: mise run container:publish <version>}"

printf '%s' "${REGISTRY_PASSWORD}" |
	podman login "${IMAGE_NAME%%/*}" --username "${REGISTRY_USERNAME}" --password-stdin

for tag in "${version}" latest; do
	podman tag "${IMAGE_NAME}:${COMMIT_SHA}" "${IMAGE_NAME}:${tag}"
	podman push "${IMAGE_NAME}:${tag}"
done
