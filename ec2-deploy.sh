#!/usr/bin/env bash
# ec2-deploy.sh — Pull latest images from GHCR and (re)start services on EC2
# Usage: Copy this to your EC2 instance alongside docker-compose.prod.yml,
#        Caddyfile, and .env, then run: ./ec2-deploy.sh
#
# Prerequisites:
#   echo $GITHUB_PAT | podman login ghcr.io -u dhan78 --password-stdin

set -euo pipefail

COMPOSE_FILE="docker-compose.prod.yml"

echo ">>> Pulling latest images from GHCR..."
podman compose -f "${COMPOSE_FILE}" pull

echo ""
echo ">>> Stopping existing containers (if any)..."
podman compose -f "${COMPOSE_FILE}" down

echo ""
echo ">>> Starting services..."
podman compose -f "${COMPOSE_FILE}" up -d

echo ""
echo ">>> Running database migrations..."
podman compose -f "${COMPOSE_FILE}" exec app npx prisma migrate deploy

echo ""
echo ">>> Services running:"
podman compose -f "${COMPOSE_FILE}" ps

echo ""
echo ">>> Done! Check logs with:"
echo "    podman compose -f ${COMPOSE_FILE} logs -f"
