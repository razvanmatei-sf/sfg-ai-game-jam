#!/bin/bash
set -e

echo "Building SF-AI-GameJam Docker Image"

IMAGE_NAME="sfg-ai-game-jam:latest"
REGISTRY_NAME="ghcr.io/razvanmatei-sf/sfg-ai-game-jam:latest"

docker buildx build --platform linux/amd64 --load -t "$IMAGE_NAME" .
docker tag "$IMAGE_NAME" "$REGISTRY_NAME"

echo $(gh auth token) | docker login ghcr.io -u razvanmatei-sf --password-stdin
docker push "$REGISTRY_NAME"

echo "Build complete"
