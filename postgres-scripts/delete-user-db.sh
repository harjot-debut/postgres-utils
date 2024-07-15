#!/bin/bash

echo ""
echo "================= Reassigning Ownership and Dropping Objects =================="
echo ""

# Reassign ownership of objects to the postgres user
echo "Reassigning ownership of objects owned by 'my_piggy' to 'postgres'..."
sudo -u postgres psql -c "REASSIGN OWNED BY my_piggy TO postgres;"

# Uncomment the following line if you want to drop all objects owned by 'my_piggy' instead of reassigning ownership
# echo "Dropping all objects owned by 'my_piggy'..."
# sudo -u postgres psql -c "DROP OWNED BY my_piggy;"

echo ""
echo "================= Dropping Database and User =================="
echo ""

# Drop the database if it exists
echo "Dropping database 'switchboarddb'..."
sudo -u postgres psql -c "DROP DATABASE IF EXISTS switchboarddb;"

# Drop the user if it exists
echo "Dropping user 'my_piggy'..."
sudo -u postgres psql -c "DROP USER IF EXISTS my_piggy;"

echo ""
echo "================= Completed Deletion =================="
echo ""
