#!/bin/bash


set -e

echo "Starting replica setup..."

# Wait for the primary to be ready
until pg_isready -h postgres-primary -p 5432 -U "$POSTGRES_USER"; do
  echo "Waiting for primary to be ready..."
  sleep 2
done

echo "Primary is ready. Setting up replication..."

# Stop the PostgreSQL service
pg_ctl -D "$PGDATA" -m fast -w stop

# Remove any existing data
rm -rf "$PGDATA"/*

# Perform base backup from primary
PGPASSWORD=$POSTGRES_PASSWORD pg_basebackup -h postgres-primary -D "$PGDATA" -U "$POSTGRES_USER" -v -P --wal-method=stream

# Create recovery configuration for streaming replication
cat > "$PGDATA/postgresql.auto.conf" <<EOF
primary_conninfo = 'host=postgres-primary port=5432 user=$POSTGRES_USER password=$POSTGRES_PASSWORD'
EOF

echo "Replication setup completed."

# Start PostgreSQL service
pg_ctl -D "$PGDATA" -w start

echo "Replica is up and running."
