# EyeLevel Kubernetes IAC Code

The repository contains logics that for deploying the GoundX RAG pipeline developed by EyeLevel AI to a self-hosted OpenShift cluster. In order for workflow described in this repository to execute successfully, please ensure the following software tool are installed on the execution environment:

# Terraform Deployment Script Documentation

The section of the documentation describes the end-user experience of this repository. The entry point to this repository is `operator.sh` file in the root of this repository. The following is a documentation of logic and usage of the file.

## Prerequisites

Before using this script, ensure you have the following:

1. Bash shell (version 4.0 or later recommended)
2. Terraform installed and available in your system PATH
3. Proper AWS credentials configured (if deploying to AWS)

## Script Structure

The script is organized into several main sections:

1. Configuration arrays (valid groups, apps, init tasks, and services)
2. Input parsing
3. Option parsing
4. Function definitions (deploy, destroy, recurse_directories)
5. Main execution logic

## Usage

```
./operator.sh [component] [options]
```

### Available Commands

#### Components
- `init`
- `services`
- `app`

#### Apps
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

#### Init Tasks
- `add`
- `config`

#### Services
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

# Interacting with the Deployed GoundX instance

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