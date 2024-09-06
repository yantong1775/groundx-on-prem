#!/bin/bash

CLOUD=$1

if [[ -z "$CLOUD" ]]; then
    echo "Usage: $0 <cloud_provider>"
    exit 1
fi

case "$CLOUD" in
  "aws")
    ;;
  "private")
    CLOUD=private/admin
    ;;

  *)
    echo "Unknown environment: $CLOUD"
    exit 1
    ;;
esac

# Initialize and apply Terraform
terraform -chdir=environments/$CLOUD init
terraform -chdir=environments/$CLOUD apply --auto-approve