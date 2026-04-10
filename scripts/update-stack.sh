#!/bin/bash
set -e

echo "Actualizando stack..."
docker compose pull
docker compose build --no-cache
docker compose up -d

echo "Stack actualizado"
