#!/bin/bash

# Enable debugging


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

echo ""
echo "=================  Testing connection to DB =================="
echo ""
PGPASSWORD="$PASSWORD" psql -h localhost -p 5432 -U $USER -d $DB_NAME -c "SELECT 1;"