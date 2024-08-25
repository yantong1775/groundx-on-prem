#!/bin/bash

docker login registry.redhat.io
aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws
docker build --platform linux/amd64 -t public.ecr.aws/c9r4x6y5/eyelevel/mysql:latest .
docker push public.ecr.aws/c9r4x6y5/eyelevel/mysql:latest