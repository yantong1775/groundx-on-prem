# EyeLevel Kubernetes IAC Code

This repository enables you to deploy the GroundX RAG document ingestion and search capabilities to a Kubernetes cluster.

## Background

The information outlined in this README was tested in the following environments:
  - Amazon Elastic Kubernetes Service (EKS)
  - Amazon OpenShift ROSA

The code in this repository will deploy the EyeLevel.ai GroundX Ingest and Search services to a Kubernetes cluster. The basic architecture of each service are as follows:

### GroundX Ingest Service

![GroundX Ingest Service](doc/groundx-ingest.jpg)

### GroundX Search Service

![GroundX Search Service](doc/groundx-search.jpg)

## Prerequisites

Please ensure you have the following software tools installed before proceeding:

1. `bash`
  - shell (version 4.0 or later recommended)
2. `terraform`
  - installed and available in your system PATH
3. Environment credentials
  - (e.g. AWS credentials)

# Quick Start Guide

## Simple Setup

### Setup Kubernetes

To setup a VPC and Kubernetes cluster in AWS:

1. Run the following command:

```
environment/aws/setup-eks
```

You will be prompted for an AWS region to set up your cluster.

### Deploy EyeLevel

To deploy the EyeLevel application into your cluster:
1. Copy `operator/env.tfvars.example` and update the configurations:
  - The ones you **MUST** modify include:
    - `admin.api_key`: Set this to a random UUID. You can generate one by running `bin/uuid`. This will be the API key associated with the admin account and will be used for inter-service communications.
    - `admin.username`: Set this to a random UUID. You can generate one by running `bin/uuid`. This will be the user ID associated with the admin account and will be used for inter-service communications.
    - `admin.email`: Set this to the email address you want associated with the admin account.
2. Run the following command:

```
operator/setup
```

Once the setup is complete, run `kubectl -n eyelevel get svc` to get the API endpoint. It will be the external IP associated with the GroundX load balancer.


## (Moderately) Advanced Setup

To get EyeLevel running in AWS, follow these steps:

- (optional) Set up a VPC, skip to the next step if you would like to use an existing VPC
  1. Copy `environment/env.tfvars.example` to `environment/env.tfvars`
  2. Modify values in `environment/env.tfvars`. The ones we recommend you consider modifying include:
    - (optional) `environment.ssh_key_name`: add the name of an SSH key if you would like to have it added to your Kubernetes nodes
    - (optional) `environment.cluster_role_arns`: add ARNs for roles you would like to grant admin access over the Kubernetes cluster to
  3. Run `bin/environment vpc -t` to do a test dry run to confirm you have configured your `env.tfvars correctly`
  4. Assuming the test dry run executed successfully, run `bin/environment vpc`
  5. The VPC setup process should take ~10 minutes and, at the end, your VPC ID, subnets, and an SSH security group ID should be printed to your terminal window

- (optional) Set up Amazon Elastic Kubernetes Service (EKS) Cluster, skip to the next step if you would like to use an existing Kubernetes cluster
  1. If you have not already done so, copy `environment/env.tfvars.example` to `environment/env.tfvars`
  2. Modify values in `environment/env.tfvars`
    - The ones you **MUST** modify include:
      - `environment.vpc_id`: set this to your VPC ID
      - `environment.subnets`: add a string array of subnet IDs
    - The ones you may want to modify include:
      - (optional) `environment.security_groups`: add 1 or more security group IDs to this array if you would like them to be applied to your nodes
      - (optional) `environment.ssh_key_name`: add the name of an SSH key if you would like to have it added to your Kubernetes nodes (note: you will also need to add a security group with SSH access rules to `environment.security_groups`)
      - (optional) `environment.cluster_role_arns`: add ARNs for roles you would like to grant admin access over the Kubernetes cluster to
  3. From the base folder, run `bin/environment eks -t` to do a test dry run to confirm you have configured your `env.tfvars correctly`
  4. Assuming the test dry run executed successfully, run `bin/environment eks`
  5. The EKS cluster setup process should take ~10 minutes

- Set up EyeLevel services
  1. Run `bin/uuid` to generate **TWO** random UUIDs. Make note of these for later.
  2. Copy `operator/env.tfvars.example` to `operator/env.tfvars`
  3. Modify values in `environment/env.tfvars`
    - The ones you **MUST** modify include:
      - `admin.api_key`: Set this to one of the random UUIDs you generated in step 1. This will be the API key associated with the admin account and will be used for inter-service communications.
      - `admin.username`: Set this to one of the random UUIDs you generated in step 1. This will be the user ID associated with the admin account and will be used for inter-service communications.
      - `admin.email`: Set this to the email address you want associated with the admin account.
  4. From the base folder, run `bin/operator init -t` to do a test dry run to confirm you have configured your `env.tfvars correctly`
  5. Assuming the test dry run executed successfully, run `bin/environment init`. This should take ~1 minute.
  6. Run `bin/operator services -t` to do a test dry run to confirm you have configured your `env.tfvars correctly`
  7. Assuming the test dry run executed successfully, run `bin/environment services`. This should take ~5 minutes.
  8. Run `bin/operator app -t` to do a test dry run to confirm you have configured your `env.tfvars correctly`
  9. Assuming the test dry run executed successfully, run `bin/environment app`. This should take ~10 minutes.

- Using EyeLevel services
  1. Go to **Interacting with the Deployed GroundX Services** for instructions on how to leverage your deployment


# Setup Instructions

## VPC and Kubernetes Cluster

`bin/environment` is a script that helps you set up a VPC and Kubernetes cluster. Hosting environments that the script currently supports can be found below.

### Usage

```
bin/environment [component] [options]
```

Component is the cloud environment or Kubernetes cluster configuration you wish to manage.

### Components
- `aws-vpc`
  - This will create a VPC and subnets for an EKS cluster
  - The resulting VPC ID and subnet IDs are required parameters for EKS cluster setup
- `eks`
  - This will set up a new EKS cluster
  - You must configure the `environment` parameters in env.tfvars, including VPC and subnet IDs

### Options

- `-c`: Clear (destroy) mode. Reverses the order of operations and destroys instead of deploys.
- `-t`: Test mode. Skips the Terraform apply/destroy step, useful for dry runs.

### Examples

1. Create a new VPC for EKS cluster setup:
   ```
   bin/environment aws-vpc
   ```

2. Create a new EKS cluster:
   ```
   bin/environment eks
   ```

3. Destroy the EKS cluster:
   ```
   bin/operator eks -c
   ```

4. Test deployment of the EKS cluster without making any changes to the AWS account:
   ```
   bin/operator eks -t
   ```

## EyeLevel Helm Operator

Deployments are managed using the `bin/operator` script found in the root of this repository.

### Usage

```
bin/operator [component] [options]
```

Component is the service, pod, configuration, or functional group you wish to manage.

### Functional Groups
- `init`
- `services`
- `app`

### App Pods
- `groundx`
- `layout-webhook`
- `pre-process`
- `process`
- `queue`
- `summary-client`
- `upload`
- `ranker`
- `layout`
- `summary`

### Init Configurations
- `add`
- `config`

### Services
- `cache`
- `db`
- `file`
- `search`
- `stream`

### Options

- `-c`: Clear (destroy) mode. Reverses the order of operations and destroys instead of deploys.
- `-t`: Test mode. Skips the Terraform apply/destroy step, useful for dry runs.

### Examples

1. Deploy all components:
   ```
   bin/operator
   ```

2. Deploy a specific group:
   ```
   bin/operator services
   ```

3. Deploy a specific app:
   ```
   bin/operator groundx
   ```

4. Destroy a specific service:
   ```
   bin/operator db -c
   ```

5. Test deployment of an init task:
   ```
   bin/operator add -t
   ```

### Customization

To add new components or modify existing ones, update the following arrays in the script:

- `valid_groups`
- `recursive_types`
- `valid_apps`
- `valid_init`
- `valid_services`

Ensure that the directory structure under the `operator/` folder matches these configurations.

### Troubleshooting

1. **"Unknown request type" error**: Check if the component you're trying to deploy/destroy is listed in the appropriate array in the script.

2. **"Directory does not exist" error**: Ensure that the directory structure under `operator/` matches the components defined in the script.

3. **Terraform errors**: Check your Terraform configurations and AWS credentials if you encounter Terraform-specific errors.

4. **Permission issues**: Ensure the script has execute permissions (`chmod +x script_name`).

For any other issues, check the Terraform output for specific error messages and consult the Terraform documentation.

# Interacting with the Deployed GroundX Services

Use `kubectl -n eyelevel get routes` to list out all the available routes from the API server, to get the API URL for your deployment.

```
from groundx import Groundx
from groundx.configuration import Configuration

groundx = Groundx(
    configuration=Configuration(
        host="{RESULT FROM GET ROUTES}/api",
        api_key="5c49be10-d228-4dd8-bbb0-d59300698ef6",
    )
)
```