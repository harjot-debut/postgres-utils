
#!/bin/bash

# Update package list and install PostgreSQL
echo "Updating package list and installing PostgreSQL..."
sudo apt-get update
sudo apt-get install -y postgresql postgresql-contrib

sudo apt install postgresql-client

# Start PostgreSQL service
echo "Starting PostgreSQL service..."
sudo systemctl start postgresql
sudo systemctl enable postgresql
