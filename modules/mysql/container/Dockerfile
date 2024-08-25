# Start with the official Red Hat MySQL image
FROM registry.redhat.io/rhel8/mysql-80:latest

# Switch to root user to make changes
USER root

# Dynamically get the UID and GID
RUN MYSQL_UID=$(id -u mysql) && MYSQL_GID=$(id -g mysql) \
    && chown -R ${MYSQL_UID}:${MYSQL_GID} /var/lib/mysql /etc/my.cnf.d /var/log/mysql /var/run/mysqld \
    && chmod -R 777 /var/lib/mysql /etc/my.cnf.d /var/log/mysql /var/run/mysqld

# Set the default user back to the OpenShift random UID
USER ${MYSQL_UID}

# Entry point for the MySQL container
CMD ["run-mysqld"]