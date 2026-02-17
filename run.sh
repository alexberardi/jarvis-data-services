#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/.env"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Error: .env not found at ${ENV_FILE}" >&2
  exit 1
fi

cd "$SCRIPT_DIR"
docker compose --env-file "$ENV_FILE" down
docker compose --env-file "$ENV_FILE" up -d
