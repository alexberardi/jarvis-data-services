#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <database_name>" >&2
  exit 1
fi

DB_NAME="$1"
if [[ ! "$DB_NAME" =~ ^[A-Za-z0-9_]+$ ]]; then
  echo "Error: database name must be alphanumeric/underscore only." >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/.env"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Error: .env not found at ${ENV_FILE}" >&2
  exit 1
fi

set -a
source "$ENV_FILE"
set +a

EXISTS="$(docker compose --env-file "$ENV_FILE" exec -T postgres \
  env PGPASSWORD="${POSTGRES_PASSWORD}" \
  psql -U "${POSTGRES_USER}" -d postgres -tAc \
  "SELECT 1 FROM pg_database WHERE datname='${DB_NAME}'")"

if [[ "$EXISTS" == "1" ]]; then
  echo "Database '${DB_NAME}' already exists."
  exit 0
fi

docker compose --env-file "$ENV_FILE" exec -T postgres \
  env PGPASSWORD="${POSTGRES_PASSWORD}" \
  psql -U "${POSTGRES_USER}" -d postgres -v ON_ERROR_STOP=1 -c \
  "CREATE DATABASE \"${DB_NAME}\";"

echo "Database '${DB_NAME}' created."
