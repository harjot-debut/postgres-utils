#!/bin/bash

# Enable debugging



set -eo pipefail

handle_error() {
  local exit_code=$?
  echo "Script failed with error on line $1: $2"
  exit $exit_code
}


# Execute SQL commands as the postgres user
echo "creating USER"

USER=$1
PASSWORD=$2
DB_NAME=$3


echo ""
echo "=================  CREATING PSQL USER  =================="
echo ""


sudo -u postgres psql -c "CREATE USER $USER WITH PASSWORD '$PASSWORD';"

echo ""
echo "=================  CREATING DATABASE  =================="
echo ""

sudo -u postgres psql -c "CREATE DATABASE $DB_NAME;"

echo ""
echo "=================  GRANTING PERMISSIONS  =================="
echo ""

sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $USER;"

echo ""
echo "=================  CREATING EXTENSION pgcrypto =================="
echo ""

sudo -u postgres psql -d $DB_NAME -c "CREATE EXTENSION IF NOT EXISTS pgcrypto;"


