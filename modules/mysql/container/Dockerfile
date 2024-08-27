# Start with the official Red Hat MySQL image
FROM registry.redhat.io/rhel8/mysql-80:latest

# Switch to root user to make changes
USER root

RUN chown -R 27:27 /var/lib/mysql /etc/my.cnf.d /var/log/mysql /var/run/mysqld \
    && chmod -R 777 /var/lib/mysql /etc/my.cnf.d /var/log/mysql /var/run/mysqld

USER 27

# Copy custom MySQL configuration file
COPY my.cnf /etc/my.cnf.d/my.cnf

# Copy SQL scripts to initialize the database
COPY init-db.sql /docker-entrypoint-initdb.d/
