#!/bin/bash

# Build and push Docker image script for ZForums
set -e

# Configuration
IMAGE_NAME="zforums/app"
TAG="${1:-latest}"
REGISTRY="${REGISTRY:-localhost:5000}"  # Default to local registry for k3s

echo "🏗️  Building ZForums application..."

# Build the Docker image
echo "Building Docker image: ${REGISTRY}/${IMAGE_NAME}:${TAG}"
docker build -t "${REGISTRY}/${IMAGE_NAME}:${TAG}" .

# Tag as latest if not already
if [ "$TAG" != "latest" ]; then
    docker tag "${REGISTRY}/${IMAGE_NAME}:${TAG}" "${REGISTRY}/${IMAGE_NAME}:latest"
fi

echo "🚀 Built image: ${REGISTRY}/${IMAGE_NAME}:${TAG}"

# Push to registry if PUSH=true
if [ "$PUSH" = "true" ]; then
    echo "📤 Pushing to registry..."
    docker push "${REGISTRY}/${IMAGE_NAME}:${TAG}"
    if [ "$TAG" != "latest" ]; then
        docker push "${REGISTRY}/${IMAGE_NAME}:latest"
    fi
    echo "✅ Pushed to registry: ${REGISTRY}/${IMAGE_NAME}:${TAG}"
fi

echo "🎉 Build complete!"
