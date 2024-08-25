# Start with the official Red Hat MySQL image
FROM registry.redhat.io/rhel8/mysql-80:latest

# Switch to root user to make changes
USER root

# Dynamically get the UID and GID
RUN chown -R mysql:mysql /var/lib/mysql /etc/my.cnf.d /var/log/mysql /var/run/mysqld \
    && chmod -R 777 /var/lib/mysql /etc/my.cnf.d /var/log/mysql /var/run/mysqld

# Set the default user back to the OpenShift random UID
USER mysql

# Copy custom MySQL configuration file
COPY my.cnf /etc/my.cnf.d/my.cnf

# Copy SQL scripts to initialize the database
COPY init-db.sql /docker-entrypoint-initdb.d/
