#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <old_name> <new_name>" >&2
  exit 1
fi

OLD_NAME="$1"
NEW_NAME="$2"

if [[ ! "$OLD_NAME" =~ ^[A-Za-z0-9_]+$ ]]; then
  echo "Error: old database name must be alphanumeric/underscore only." >&2
  exit 1
fi

if [[ ! "$NEW_NAME" =~ ^[A-Za-z0-9_]+$ ]]; then
  echo "Error: new database name must be alphanumeric/underscore only." >&2
  exit 1
fi

if [[ "$OLD_NAME" == "$NEW_NAME" ]]; then
  echo "Error: old and new names are the same." >&2
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

OLD_EXISTS="$(docker compose --env-file "$ENV_FILE" exec -T postgres \
  env PGPASSWORD="${POSTGRES_PASSWORD}" \
  psql -U "${POSTGRES_USER}" -d postgres -tAc \
  "SELECT 1 FROM pg_database WHERE datname='${OLD_NAME}'")"

if [[ "$OLD_EXISTS" != "1" ]]; then
  echo "Error: database '${OLD_NAME}' does not exist." >&2
  exit 1
fi

NEW_EXISTS="$(docker compose --env-file "$ENV_FILE" exec -T postgres \
  env PGPASSWORD="${POSTGRES_PASSWORD}" \
  psql -U "${POSTGRES_USER}" -d postgres -tAc \
  "SELECT 1 FROM pg_database WHERE datname='${NEW_NAME}'")"

if [[ "$NEW_EXISTS" == "1" ]]; then
  echo "Error: database '${NEW_NAME}' already exists." >&2
  exit 1
fi

# Terminate existing connections to the database
docker compose --env-file "$ENV_FILE" exec -T postgres \
  env PGPASSWORD="${POSTGRES_PASSWORD}" \
  psql -U "${POSTGRES_USER}" -d postgres -v ON_ERROR_STOP=1 -c \
  "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname='${OLD_NAME}' AND pid <> pg_backend_pid();" \
  >/dev/null 2>&1 || true

docker compose --env-file "$ENV_FILE" exec -T postgres \
  env PGPASSWORD="${POSTGRES_PASSWORD}" \
  psql -U "${POSTGRES_USER}" -d postgres -v ON_ERROR_STOP=1 -c \
  "ALTER DATABASE \"${OLD_NAME}\" RENAME TO \"${NEW_NAME}\";"

echo "Database '${OLD_NAME}' renamed to '${NEW_NAME}'."
