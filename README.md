# EyeLevel Kubernetes IAC Code

This repository enables you to deploy the GroundX RAG document ingestion and search capabilities, developed by EyeLevel.ai, to a self-hosted Kubernetes cluster. The code has been tested on OpenShift ROSA on AWS.

# Helm Operator Instructions

## Prerequisites

Please ensure you have the following software tools installed before proceeding:

1. Bash shell (version 4.0 or later recommended)
2. Terraform, installed and available in your system PATH
3. Proper AWS credentials (if deploying to AWS)

## Usage

Deployments are managed using the `operator.sh` script found in the root of this repository.

```
./operator.sh [component] [options]
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

## Examples

1. Deploy all components:
   ```
   ./operator.sh
   ```

2. Deploy a specific group:
   ```
   ./operator.sh services
   ```

3. Deploy a specific app:
   ```
   ./operator.sh groundx
   ```

4. Destroy a specific service:
   ```
   ./operator.sh db -c
   ```

5. Test deployment of an init task:
   ```
   ./operator.sh add -t
   ```

## Customization

To add new components or modify existing ones, update the following arrays in the script:

- `valid_groups`
- `recursive_types`
- `valid_apps`
- `valid_init`
- `valid_services`

Ensure that the directory structure under the `operator/` folder matches these configurations.

## Troubleshooting

1. **"Unknown request type" error**: Check if the component you're trying to deploy/destroy is listed in the appropriate array in the script.

2. **"Directory does not exist" error**: Ensure that the directory structure under `operator/` matches the components defined in the script.

3. **Terraform errors**: Check your Terraform configurations and AWS credentials if you encounter Terraform-specific errors.

4. **Permission issues**: Ensure the script has execute permissions (`chmod +x script_name.sh`).

For any other issues, check the Terraform output for specific error messages and consult the Terraform documentation.

# Interacting with the Deployed GroundX instance

Use `kubectl -n eyelevel get routes` to list out all the available routes from the API server.

To get API URL.

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

### SELF-SIGNED CERTS
```
openssl genrsa -out ca.key 2048
openssl req -x509 -new -nodes -key ca.key -sha256 -days 3650 -out ca.crt -subj "/CN=self-signed-ca"
openssl req -new -key tls.key -out tls.csr -subj "/CN={PUT YOUR CLUSTER NAME HERE}.{PUT YOUR NAMESPACE HERE}.svc"
openssl x509 -req -in tls.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out tls.crt -days 3650 -sha256
```