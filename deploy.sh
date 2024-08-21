#!/bin/bash

ENV=$1
CLOUD=$2

CLUSTER_NAME=eyelevel
REGION=us-east-2

if [[ -z "$ENV" || -z "$CLOUD" ]]; then
    echo "Usage: $0 <environment> <cloud_provider>"
    exit 1
fi

case "$CLOUD" in
  "aws")
    echo "Setting up kubeconfig for AWS EKS"
    aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME
    ;;

  *)
    echo "Unknown environment: $CLOUD"
    exit 1
    ;;
esac

# Navigate to the correct environment directory
cd environments/$CLOUD/$ENV

# Initialize and apply Terraform
terraform init
terraform apply -auto-approve

# Run Helm to deploy applications
helmfile -f helmfiles/helmfile.yaml sync

# Run Ansible playbooks
ansible-playbook ansible_playbook.yaml
