#!/bin/bash
# TODO Add variables for database and schema names based on what the image uses
set -e

psql -v ON_ERROR_STOP=1 -c "CREATE SCHEMA IF NOT EXISTS widget AUTHORIZATION $POSTGRES_USER; ALTER DATABASE widget SET search_path TO widget;" --username "$POSTGRES_USER"

