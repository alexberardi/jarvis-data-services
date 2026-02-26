# jarvis-data-services

Shared data infrastructure for all Jarvis services. **Not a running service** — this is Docker Compose orchestration for databases and object storage.

## Quick Reference

```bash
# Start all infrastructure
./run.sh

# Or manually
docker compose up -d

# Check status
docker compose ps

# Create a new database
./create-db.sh <db_name>

# Drop a database
./drop-db.sh <db_name>
```

## Services Provided

| Service | Port | Purpose |
|---------|------|---------|
| PostgreSQL 16 | 5432 | Primary database for all services |
| pgAdmin 4 | 5050 | Database web UI |
| MinIO (S3) | 9000/9001 | Object storage (recipe images, media) |
| Redis 7 | 6379 | Queue backend (OCR, LLM training jobs) |
| Redis Commander | 8081 | Redis web UI (optional `tools` profile) |

## Environment Variables

Configured in `.env`:

| Variable | Default | Description |
|----------|---------|-------------|
| `POSTGRES_USER` | postgres | PostgreSQL superuser |
| `POSTGRES_PASSWORD` | postgres | PostgreSQL password |
| `POSTGRES_DB` | app | Default database |
| `POSTGRES_PORT` | 5432 | PostgreSQL port |
| `PGADMIN_DEFAULT_EMAIL` | admin@example.com | pgAdmin login email |
| `PGADMIN_DEFAULT_PASSWORD` | admin | pgAdmin login password |
| `MINIO_ROOT_USER` | minioadmin | MinIO access key |
| `MINIO_ROOT_PASSWORD` | minioadmin | MinIO secret key |
| `REDIS_PASSWORD` | redis | Redis password |

## Scripts

- `run.sh` — Start all infrastructure via Docker Compose
- `create-db.sh <name>` — Create a new PostgreSQL database
- `drop-db.sh <name>` — Drop a PostgreSQL database
- `rename-db.sh <old> <new>` — Rename a database

## Used By

Every service with a database dependency connects to this PostgreSQL instance. Services using Redis (jarvis-llm-proxy-api, jarvis-ocr-service, jarvis-recipes-server) connect to this Redis instance.

## Relationship to jarvis-data-stores

- **jarvis-data-services**: Production-oriented minimal setup
- **jarvis-data-stores**: Dev-focused with extra tooling (RedisInsight, Mosquitto MQTT)

Both provide the same core infrastructure; use whichever fits your environment.
