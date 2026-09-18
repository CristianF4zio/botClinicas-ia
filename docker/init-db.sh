#!/bin/bash
# Se ejecuta una sola vez, al crear el volumen de Postgres por primera vez.
# Postgres ya crea la base $POSTGRES_DB (n8n) automáticamente; acá creamos
# la segunda base donde vivirán las tablas de citas y conversaciones.
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "postgres" <<-EOSQL
    CREATE DATABASE ${CLINICA_DB_NAME:-clinica};
EOSQL
