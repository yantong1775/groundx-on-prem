#!/bin/bash

ENV=$1
CLOUD=$2

if [[ -z "$ENV" || -z "$CLOUD" ]]; then
    echo "Usage: $0 <environment> <cloud_provider>"
    exit 1
fi

case "$CLOUD" in
  "aws")
    ;;
  "onprem")
    ;;

  *)
    echo "Unknown environment: $CLOUD"
    exit 1
    ;;
esac

# Initialize and apply Terraform
terraform -chdir=environments/$CLOUD/$ENV init
terraform -chdir=environments/$CLOUD/$ENV apply --auto-approve