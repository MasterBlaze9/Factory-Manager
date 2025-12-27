#!/usr/bin/env bash
set -euo pipefail

# Simple helper to start DB containers and import the provided SQL schema
# Requires docker & docker-compose

PROJECT_NAME=${COMPOSE_PROJECT_NAME:-factorymgmt}

# Accept a --reset flag to remove existing DB volumes (useful after a bad import)
RESET=${1:-}
if [ "$RESET" = "--reset" ]; then
  echo "Reset requested: stopping containers and removing DB volumes..."
  docker-compose down
  docker volume rm $(docker volume ls -qf name=${PROJECT_NAME}_postgres_data) 2>/dev/null || true
  docker volume rm $(docker volume ls -qf name=${PROJECT_NAME}_mongo_data) 2>/dev/null || true
fi

echo "Starting Postgres, Mongo and web (Django) containers..."
# If the web image already exists, don't force a rebuild (avoids pulling base image metadata when not needed)
if docker image inspect factory-management-web:latest >/dev/null 2>&1; then
  docker-compose up -d db mongo web || docker-compose up -d db mongo web --build
else
  docker-compose up -d db mongo web --build
fi

echo "Waiting for Postgres to become ready..."
for i in {1..30}; do
  if docker-compose exec -T db pg_isready -U "${POSTGRES_USER:-factoryuser}" -d "${POSTGRES_DB:-factorydb}" >/dev/null 2>&1; then
    echo "Postgres is ready"
    break
  fi
  echo "Postgres not ready yet ($i/30)..."
  sleep 2
done

echo "Running Django migrations inside the web container..."
docker-compose exec -T web python3 manage.py migrate

echo "Importing SQL schema into Postgres (after migrations)..."
docker-compose exec -T db psql -U "${POSTGRES_USER:-factoryuser}" -d "${POSTGRES_DB:-factorydb}" -f /sql/create_tables_script_final.sql || true
echo "Schema import attempted (some statements may be skipped if objects already exist)."

echo "Seeding MongoDB inside the web container (optional)..."
docker-compose exec -T web python3 /app/scripts/seed_mongo.py || true

echo "Applying db_objects SQL files from /sql_objects into Postgres..."
# iterate over subdirectories and .sql files
docker-compose exec -T db bash -lc '
  set -e
  for sql in /sql_objects/*/*.sql; do
    if [ -f "$sql" ]; then
      echo "Applying $sql";
      psql -U "${POSTGRES_USER:-factoryuser}" -d "${POSTGRES_DB:-factorydb}" -f "$sql" || true;
    fi
  done
'
echo "db_objects SQL application finished."

echo "All done. The Django dev server should be running on http://localhost:8000 (if the web container started it)."
