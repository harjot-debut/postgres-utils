#!/bin/bash



set -eo pipefail

handle_error() {
  local exit_code=$?
  echo "Script failed with error on line $1: $2"
  exit $exit_code
}

# Check if PostgreSQL is installed
if ! command -v psql &> /dev/null
then
    echo "PostgreSQL is not installed. Installing..."
    # Update package list and install PostgreSQL
    sudo apt-get update
    # sudo apt-get install -y postgresql postgresql-contrib
    sudo apt install postgresql-14 -y
    systemctl status postgresql
    # sudo apt install postgresql-client
else
    echo "PostgreSQL is already installed."
fi

# Check if PostgreSQL service is running
if sudo systemctl is-active --quiet postgresql
then
    echo "PostgreSQL service is running."
else
    echo "Starting PostgreSQL service..."
    sudo systemctl start postgresql
    sudo systemctl enable postgresql
fi
