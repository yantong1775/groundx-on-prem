# Start with the official Red Hat MySQL image
FROM registry.redhat.io/rhel8/redis-6:latest

# Switch to root user to make changes
USER root

# Ensure the Redis user can read the configuration file
RUN chown redis:redis /etc/redis.conf \
    && chmod 777 /etc/redis.conf

# Create the required directories and set permissions
RUN mkdir -p /mnt/redis && \
    chown -R redis:redis /mnt/redis && \
    chown -R redis:redis /var/lib/redis && \
    chown -R redis:redis /etc/redis.conf && \
    chmod -R 777 /etc/redis.conf && \
    chmod -R 777 /var/lib/redis && \
    chmod -R 777 /mnt/redis

# Set the default user back to the OpenShift random UID
USER redis

# Start Redis server when the container starts
CMD ["redis-server", "/etc/redis.conf"]
