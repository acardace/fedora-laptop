#!/bin/bash
set -euo pipefail

IMAGE_NAME="${IMAGE_NAME:-localhost/fedora-laptop}"
IMAGE_TAG="${IMAGE_TAG:-latest}"

echo "Building base image: ${IMAGE_NAME}:base"

podman build \
    -f Containerfile.base \
    -t "${IMAGE_NAME}:base" \
    .

echo "✓ Base image built successfully: ${IMAGE_NAME}:base"

echo "Building bootc image: ${IMAGE_NAME}:${IMAGE_TAG}"

podman build \
    -f Containerfile.bootc \
    -t "${IMAGE_NAME}:${IMAGE_TAG}" \
    .

echo "✓ Image built successfully: ${IMAGE_NAME}:${IMAGE_TAG}"
podman images "${IMAGE_NAME}:${IMAGE_TAG}"
