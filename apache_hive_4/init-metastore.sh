#!/bin/bash

set -e

echo "Waiting for PostgreSQL to be ready..."
until pg_isready -h postgres -p 5432 -U hive; do
  echo "Postgres is unavailable - sleeping 3s"
  sleep 3
done

echo "Checking for PostgreSQL JDBC driver..."
if [ ! -f /opt/hive/lib/postgresql-*.jar ]; then
  echo "PostgreSQL JDBC driver NOT found in /opt/hive/lib!"
  echo "Please add driver jar before running this script."
  exit 1
else
  echo "PostgreSQL JDBC driver found."
fi

echo "Initializing Hive Metastore schema with PostgreSQL..."
schematool -dbType postgres -initSchema -verbose

if [ $? -eq 0 ]; then
  echo "Hive Metastore schema initialized successfully."
else
  echo "Schema initialization FAILED!"
  exit 1
fi
