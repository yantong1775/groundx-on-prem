# Table of Contents

- [Table of Contents](#table-of-contents)
  - [What is GroundX On-Prem?](#what-is-groundx-on-prem)
    - [GroundX Ingest Service](#groundx-ingest-service)
    - [GroundX Search Service](#groundx-search-service)
  - [Quick Start](#quick-start)
    - [Existing Kubernetes Cluster](#existing-kubernetes-cluster)
    - [New Amazon EKS Cluster](#new-amazon-eks-cluster)
      - [Creating the VPC and EKS Cluster](#creating-the-vpc-and-eks-cluster)
      - [Deploying GroundX On-Prem to the EKS Cluster](#deploying-groundx-on-prem-to-the-eks-cluster)
      - [A Note on Cost](#a-note-on-cost)
  - [Using GroundX On-Prem](#using-groundx-on-prem)
    - [Getting the API Endpoint](#getting-the-api-endpoint)
    - [Using the SDKs](#using-the-sdks)
    - [Using the APIs](#using-the-apis)
  - [Tear Down](#tear-down)

## What is GroundX On-Prem?

With this repository you can deploy GroundX RAG document ingestion and search capabilities to a Kubernetes cluster in a manner that can be isolated from any external dependencies.

GroundX delivers a unique approach to advanced RAG that consists of three interlocking systems:

1. **GroundX Ingest:** A state-of-the-art vision model trained on over 1M pages of enterprise documents. It delivers unparalleled document understanding and can be fine-tuned for your unique document sets.
2. **GroundX Store:** Secure, encrypted storage for source files, semantic objects, and vectors, ensuring your data is always protected.
3. **GroundX Search:** Built on OpenSearch, it combines text and vector search with a fine-tuned re-ranker model for precise, enterprise-grade results.

In head-to-head testing, GroundX significantly outperforms many popular RAG tools ([ref1](https://www.eyelevel.ai/post/most-accurate-rag), [ref2](https://www.eyelevel.ai/post/guide-to-document-parsing), [ref3](https://www.eyelevel.ai/post/do-vector-databases-lose-accuracy-at-scale)), especially with respect to complex documents at scale. GroundX is trusted by organizations like Air France, Dartmouth and Samsung with over 2 billion tokens ingested on our models.

GroundX On-Prem allows you to leverage GroundX within hardened and secure environments. GroundX On-Prem requires no external dependencies when running, meaning it can be used in air-gapped environments. Deployment consists of two key steps:

1. (Optional) Creation of Infrastructure on AWS via Terraform
2. Deployment of GroundX onto Kubernetes via Helm

Currently, creation of infrastructure via Terraform is only supported for AWS. However, with sufficient expertise GroundX can be deployed onto any pre-existing Kubernetes cluster.

This repo is in Open Beta. Feedback is appreciated and encouraged. To use the hosted version of GroundX visit [EyeLevel.ai](https://www.eyelevel.ai/). For white glove support in configuring this open source repo in your environment, or to access more performant and closed source versions of this repo, [contact us](https://www.eyelevel.ai/product/request-demo). To learn more about what GroundX is, and what it's useful for, you may be interested in the following resources:

- [A Video discussion the importance of parsing, and a comparison of several approaches](https://www.youtube.com/watch?v=7Vv64f1yI0I&t=1108s)
- [GroundX being used to power a multi-modal RAG application](https://www.youtube.com/watch?v=tIiqCG11hzQ)
- [GroundX being used to power a verbal AI Agent](https://www.youtube.com/watch?v=BL2G3C3_RZU&t=300s)

### GroundX Ingest Service

The GroundX ingest service expects visually complex documents in a variety of formats. It analyzes those documents with several fine tuned models, converts the documents into a queryable representation which is designed to be understood by LLMs, and stores that information for downstream search.

![GroundX Ingest Service](doc/groundx-ingest.jpg)

### GroundX Search Service

Once documents have been processed via the ingest service they can be queried against via natural language queries. We use a custom configuration of Open Search which has been designed in tandem with the representations generated from the ingest service.

![GroundX Search Service](doc/groundx-search.jpg)

## Quick Start

Please ensure you have the following software tools installed before proceeding:

- `bash` shell (version 4.0 or later recommended. AWS Cloud Shell has insufficient resources.)
- `terraform` ([Setup Docs](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli))
- `kubectl` ([Setup Docs](https://kubernetes.io/docs/tasks/tools/))

If you will be using the Terraform scripts to set up infrastructure in AWS, you will also need:

- `AWS CLI` ([Setup Docs](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html))


### Existing Kubernetes Cluster

This section describes how to deploy GroundX On-Prem to an existing Kubernetes cluster.

If you do not have an existing Kubernetes cluster and would like to use our Terraform scripts to set up an Amazon EKS cluster up, you should follow the new Amazon EKS cluster [Quick Start guide](#new-amazon-eks-cluster).

```text
<TODO> Sorry Ben, I don't understand enough to know what to write here.

My thinking was, it can be difficult to follow fragmented tutorials, so I made end-to-end documentation for each major use case, and aligned it with the existing documentation.

So, there's three:
1. full setup with little config
2. full setup with a lot of config
3. only deploying GroundX on an existing Kubernetes

This is #3, and I don't understand enough to write it.
```

### New Amazon EKS Cluster

This section describes how to create a new VPC and EKS cluster in AWS and deploy GroundX On-Prem to the EKS cluster.

If you already have a Kubernetes cluster, including an existing AWS EKS cluster, you should follow the existing Kubernetes cluster [Quick Start guide](#existing-kubernetes-cluster).

#### Creating the VPC and EKS Cluster

1. Create env.tfvars file

```bash
cp environment/aws/env.tfvars.example environment/aws/env.tfvars
```

`env.tfvars` is the configuration file Terraform will use when defining the resources. The content of `env.tfvars` will be updated in subsequent steps.

2. Once `env.tfvars` has been created, run:

```bash
environment/aws/setup-eks
```

You will be prompted for an AWS region to set up your cluster, and will also be asked to double check that you're happy with the state of the configuration file.

Once this command has executed, a VPC and Kubernetes cluster will be setup. You can proceed to deploying GroundX.

#### Deploying GroundX On-Prem to the EKS Cluster

1. Create env.tfvars file

```bash
cp operator/env.tfvars.example operator/env.tfvars
```

This creates a Terraform configuration file for the GroundX application, similarl to what was described in the previous section. Now, however, some configuration is required.

2. Add admin credentials

For security reasons, you **MUST** modify the following:

- `admin.api_key`: Set this to a random UUID. You can generate one by running `bin/uuid`. This will be the API key associated with the admin account and will be used for inter-service communications.
- `admin.username`: Set this to a random UUID. You can generate one by running `bin/uuid`. This will be the user ID associated with the admin account and will be used for inter-service communications.
- `admin.email`: Set this to the email address you want associated with the admin account.

3. Once `env.tfvars` has been properly configured, run:

```bash
operator/setup
```

This will create a new namespace and deploy GroundX On-Prem into the Kubernetes cluster.

#### A Note on Cost

The resources being created will incur cost via AWS. It is recommended to follow all instructions accurately and completely. So that setup and taredown are both executed completely. Experience with AWS is recommended.

The default resource configurations are specified [here](https://github.com/eyelevelai/eyelevel-iac/blob/main/README.md#:~:text=configurations%20are%20specified-,here,-%2C%20consisting%20of%3A), consisting of:

```text
2x m6a.xlarge
3x t3a.medium
1x g4dn.xlarge
3x g4dn.2xlarge
2x g5.xlarge
~300 GB gp2
```

## Using GroundX On-Prem

### Getting the API Endpoint

Once the setup is complete, run:

```bash
kubectl -n eyelevel get svc
```

The API endpoint will be the external IP associated with the GroundX load balancer.

For instance, the "external IP" might resemble the following:

```bash
EXTERNAL-IP
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx-xxxxxxxxxx.us-east-2.elb.amazonaws.com
```

### Using the SDKs

The [API endpoint](#getting-the-api-endpoint), in conjuction with the `admin.api_key` defined during deployment, can be used to configure the GroundX SDK to communicate with your On-Prem instance of GroundX.

Note: you must append `/api` to your [API endpoint](#getting-the-api-endpoint) in the SDK configuration.

```python
from groundx import Groundx
from groundx.configuration import Configuration

external_ip = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx-xxxxxxxxxx.us-east-2.elb.amazonaws.com'

groundx = Groundx(
    configuration=Configuration(
        host=f"http://{external_ip}/api",
        api_key="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
    )
)
```

```typescript
import { Groundx } from "groundx-typescript-sdk";

const external_ip = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx-xxxxxxxxxx.us-east-2.elb.amazonaws.com'

const groundx = new Groundx({
  apiKey: "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  basePath: `http://${external_ip}/api`;,
});
```

### Using the APIs

The [API endpoint](#getting-the-api-endpoint), in conjuction with the `admin.api_key` defined during deployment, can be used to interact with your On-Prem instance of GroundX.

All of the methods and operations described in the [GroundX documentation](https://documentation.groundx.ai/reference) are supported with your On-Prem instance of GroundX. You simply have to substitute `https://api.groundx.ai` with your [API endpoint](#getting-the-api-endpoint).

```
POST
https://api.groundx.ai/api/v1/ingest/documents/remote
```

## Tear Down

After all resources have been created, tear down can be done with the following commands.

```bash
bin/operator app -c
bin/operator services -c
bin/operator init -c
bin/environment eks -c
bin/environment aws-vpc -c
```

It is vital to run these commands in order, and it is recommended to run them one at a time manually. We have observed inconsistency and race conditions when these are run automatically.
