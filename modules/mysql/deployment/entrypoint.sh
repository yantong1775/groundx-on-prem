#!/bin/bash
set -e

# Start the MySQL service in the background
docker-entrypoint.sh mysqld &

# Wait for MySQL to be ready
until mysqladmin ping --silent -u root -p"${MYSQL_ROOT_PASSWORD}"; do
    echo "Waiting for MySQL to be up..."
    sleep 2
done

# Create the user and grant privileges if they don't already exist
mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
"

# Keep the MySQL process running
wait

