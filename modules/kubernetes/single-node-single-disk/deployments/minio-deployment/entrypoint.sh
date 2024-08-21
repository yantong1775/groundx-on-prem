#!/bin/sh

# Start MinIO server in the background
minio server /data --console-address :9001 &

# Wait for MinIO to start up
sleep 10

# Run the mc command to add the user
mc alias set local http://localhost:9000 $MINIO_ROOT_USER $MINIO_ROOT_PASSWORD
mc admin user add local ROOTNAME CHANGEME123

# Wait for the MinIO server to keep running
wait -n
