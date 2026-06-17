# jarvis-data-services

Shared data infrastructure for the Jarvis stack. This is **not a running
service** — it is a Docker Compose bundle that brings up the databases, cache,
and object storage that the other Jarvis services depend on.

## Services provided

| Service          | Port        | Purpose                                    |
|------------------|-------------|--------------------------------------------|
| PostgreSQL 16    | 5432        | Primary database for all services          |
| pgAdmin 4        | 5050        | Database web UI                            |
| MinIO (S3)       | 9000 / 9001 | Object storage (images, media)             |
| Redis 7          | 6379        | Queue backend (OCR, LLM training jobs)     |
| Redis Commander  | 8081        | Redis web UI (optional `tools` profile)    |

## Usage

```bash
# Start all infrastructure
./run.sh

# ...or with Docker Compose directly
docker compose up -d

# Check status
docker compose ps
```

### Managing databases

```bash
./create-db.sh <db_name>          # create a new PostgreSQL database
./drop-db.sh <db_name>            # drop a database
./rename-db.sh <old> <new>        # rename a database
```

## Configuration

Credentials and ports are set via a `.env` file. Key variables (with defaults):

| Variable                  | Default             |
|---------------------------|---------------------|
| `POSTGRES_USER`           | postgres            |
| `POSTGRES_PASSWORD`       | postgres            |
| `POSTGRES_DB`             | app                 |
| `POSTGRES_PORT`           | 5432                |
| `PGADMIN_DEFAULT_EMAIL`   | admin@example.com   |
| `PGADMIN_DEFAULT_PASSWORD`| admin               |
| `MINIO_ROOT_USER`         | minioadmin          |
| `MINIO_ROOT_PASSWORD`     | minioadmin          |
| `REDIS_PASSWORD`          | redis               |

Override these in `.env` before starting; do not commit real secrets.

## Used by

Every Jarvis service with a database dependency connects to this PostgreSQL
instance. Services that use Redis (jarvis-llm-proxy-api, jarvis-ocr-service,
jarvis-recipes-server) connect to this Redis instance.

## License

GNU Affero General Public License v3.0. See [LICENSE](LICENSE).
