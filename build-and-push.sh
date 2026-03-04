#!/usr/bin/env bash
# build-and-push.sh — Build Docker images and push to GHCR
# Usage: ./build-and-push.sh [tag]
#   tag defaults to "latest"
#
# Prerequisites:
#   1. Log in to GHCR first:
#      echo $GITHUB_PAT | podman login ghcr.io -u dhan78 --password-stdin
#
#   2. Create a GitHub Personal Access Token (classic) with:
#      - write:packages
#      - read:packages
#      - delete:packages (optional)

set -euo pipefail

GHCR_OWNER="dhan78"
TAG="${1:-latest}"
PROSTORE_IMAGE="ghcr.io/${GHCR_OWNER}/prostore:${TAG}"
JDLAB_IMAGE="ghcr.io/${GHCR_OWNER}/jdlab:${TAG}"

echo "============================================"
echo "  Building images with tag: ${TAG}"
echo "============================================"

# --- Build Prostore ---
echo ""
echo ">>> Building Prostore image..."
podman build \
  --build-arg NEXT_PUBLIC_APP_NAME="${NEXT_PUBLIC_APP_NAME:-Prostore}" \
  --build-arg NEXT_PUBLIC_APP_DESCRIPTION="${NEXT_PUBLIC_APP_DESCRIPTION:-A modern ecommerce store built with Next.js}" \
  --build-arg NEXT_PUBLIC_SERVER_URL="${NEXT_PUBLIC_SERVER_URL:-https://shop.jdlab.us}" \
  --build-arg NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY="${NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY:-}" \
  -t "${PROSTORE_IMAGE}" \
  -f Dockerfile \
  .

# --- Build jdlab (assumes ../jdlab-public exists) ---
if [ -d "../jdlab-public" ]; then
  echo ""
  echo ">>> Building jdlab image..."
  podman build \
    -t "${JDLAB_IMAGE}" \
    -f ../jdlab-public/Dockerfile \
    ../jdlab-public
else
  echo ""
  echo ">>> Skipping jdlab build (../jdlab-public not found)"
fi

echo ""
echo "============================================"
echo "  Pushing images to GHCR"
echo "============================================"

echo ""
echo ">>> Pushing ${PROSTORE_IMAGE}..."
podman push "${PROSTORE_IMAGE}"

if podman image inspect "${JDLAB_IMAGE}" &>/dev/null; then
  echo ""
  echo ">>> Pushing ${JDLAB_IMAGE}..."
  podman push "${JDLAB_IMAGE}"
fi

echo ""
echo "============================================"
echo "  Done! Images pushed to GHCR:"
echo "    ${PROSTORE_IMAGE}"
podman image inspect "${JDLAB_IMAGE}" &>/dev/null && echo "    ${JDLAB_IMAGE}"
echo ""
echo "  On EC2, run:"
echo "    podman compose -f docker-compose.prod.yml pull"
echo "    podman compose -f docker-compose.prod.yml up -d"
echo "============================================"
