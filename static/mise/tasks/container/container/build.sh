#!/usr/bin/env bash

#MISE description = "Build the container image"
#MISE env.COMMIT_SHA = "{{vars.commit_sha}}"
#MISE env.REPO_URL = "{{vars.repo_url}}"
#MISE env.REPO_NAME = "{{vars.repo_name}}"
#MISE env.REPO_OWNER = "{{vars.repo_owner}}"
#MISE env.IMAGE_DESCRIPTION = "{{vars.image_description}}"
#MISE env.IMAGE_LICENSES = "{{vars.image_licenses}}"

set -euo pipefail

podman build --format docker --isolation chroot --ulimit nofile=65536:65536 --cache-from "${IMAGE_NAME}" \
	-t "${IMAGE_NAME}:${COMMIT_SHA}" \
	--label "org.opencontainers.image.source=${REPO_URL}" \
	--label "org.opencontainers.image.title=${REPO_NAME}" \
	--label "org.opencontainers.image.vendor=${REPO_OWNER}" \
	--label "org.opencontainers.image.description=${IMAGE_DESCRIPTION}" \
	--label "org.opencontainers.image.licenses=${IMAGE_LICENSES}" \
	./src
