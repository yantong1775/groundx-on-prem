# pdf-extraction
PDF Extraction Infrastructure Setup

## See Groundx-on-prem repo for reference
Setup procedure are similar to groundx-on-prem.
https://github.com/eyelevelai/groundx-on-prem

## Dependencies

GroundX On-Prem requires Kubernetes cluster v1.18+.

Please ensure you also have the following software tools installed before proceeding:

- bash shell (version 4.0 or later recommended. AWS Cloud Shell has insufficient resources.)
- terraform (Setup Docs)
- kubectl (Setup Docs)
- gcloud CLI

## Provision the gke cluster and vpc

Before Running the commnad, make sure env.tfvars are created.

Running the following code, the vpc and gke cluster will be created

```bash
cd environment/gcp
chmod +x setup.sh
./setup.sh
```

setup.sh will prompt user to input the gcp project_id, region and the zones.

## Deploy groundx on prem to gke cluster

After the gke cluster is setup, update the operator/env.tfvars with your cluster information

For security reasons, you MUST modify the following,

- admin.api_key: Set this to a random UUID. You can generate one by running bin/uuid. This will be the API key associated with the admin account and will be used for inter-service communications.
- admin.username: Set this to a random UUID. You can generate one by running bin/uuid. This will be the user ID associated with the admin account and will be used for inter-service communications.
- admin.email: Set this to the email address you want associated with the admin account.

You can also update the password and pod resource configurations, Please refer to https://github.com/eyelevelai/groundx-on-prem#create-envtfvars-file.


```bash
cd operator/init
./setup.sh
cd ../..
bin/operator service
bin/operator app
```

## Tearing Down

After all resources have been created, tear down can be done with the following commands.

To tear down the GroundX On-Prem deployment, run the following commands in order:

```bash
bin/operator app -c
bin/operator services -c
cd operator/init
./destroy.sh
```

To tear down the gke cluser
```bash
cd environment/gcp
./destroy.sh
```

## Test it
Get the cluster services public ip by running 
```bash
kubectl get svc -n eyelevel
```
Go to the test folder, and use the jupyter notebook to test if the cluster is working.

api documentation is at https://docs.eyelevel.ai/reference/api-reference/documents/ingest.

## Resources Used

The GroundX On-Prem default resource requirements are:

```text
eyelevel-cpu-only (e2-standard-4)
    20 GB     disk drive space
    2         CPU cores
    8 GB     RAM

eyelevel-cpu-memory (n2-standard-4)
    40 GB     disk drive space
    4         CPU cores
    16 GB     RAM

eyelevel-gpu-layout (n1-standard-4)
    16 GB     GPU memory
    15 GB     disk drive space
    4         CPU cores
    12 GB     RAM

eyelevel-gpu-ranker (a2-highgpu-1g)
    40 GB     GPU memory
    100 GB    disk drive space
    12        CPU cores
    85 GB     RAM

eyelevel-gpu-summary (a2-ultragpu-1g)
    80 GB     GPU memory
    375 GB    disk drive space
    12        CPU cores
    170 GB     RAM
```
