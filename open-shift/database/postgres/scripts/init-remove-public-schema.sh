#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 -c 'REVOKE ALL ON SCHEMA public FROM public; DROP SCHEMA IF EXISTS public CASCADE;' --username "$POSTGRES_USER"

