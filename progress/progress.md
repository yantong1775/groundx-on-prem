# Progress

# 02/18

1. Change Tolerations for summary_inference and rank_inference to nvidia.com/gpu = present. To fix the pod unschedulerable error.
2. Locate the bug for persistent volume claim. The original PVC has ReadWriteMany access type, gke doesn't support rwx. There are some solutions to that:
   1. Just change the access type to read write only, this allows only the current node can perform read and write to the pod. (while rwx allows multiple nodes to perform read and write). 
   2. Use gke provided filestore or cloud storage fuse csi. file store seems like an overkill, I can only provision 1Tib at minimum. cloud storage fuse csi is object store, I'm not sure if it's suitable here.
   3. Use gke on aws, need to explore this one, not sure how to do it. 
3. While "fix" the second bug by changing the access type to rwo, there's another bug. When loading the model, it shows:
   ```
   safetensors_rust.SafetensorError: Error while deserializing header: MetadataIncompleteBuffer
   ```
   It looks like the safetensor is corrupted. maybe the downloading? i'll check the checksum after downloading.

### TODO
1. fix the safetensor corrupt
2. need to confirm if the previous fix to persistent volume claim is valid.


### reference
https://cloud.google.com/kubernetes-engine/docs/concepts/persistent-volumes
https://cloud.google.com/kubernetes-engine/multi-cloud/docs/aws/how-to/storage-class#ebs-volume
https://cloud.google.com/kubernetes-engine/docs/concepts/cloud-storage-fuse-csi-driver
https://cloud.google.com/kubernetes-engine/docs/concepts/filestore-for-gke


## 02/14

### TODO

1. try fix service error
2. try deploy app

## 02/13

most service deployed successfully.

1. kafka-cluster-entity-operator show error:
   1. Session 0x0 for sever localhost/127.0.0.1:2181, Closing socket connection. Attempting reconnect except it is a SessionExpiredException.
      java.net.ConnectException: Connection refused
      Possible cause: zoo keeper is down?

## 02/12

### TODO

1. fix the daemon no node selected if it is an issue
2. find out what's going on with the terraform code, why directly using helm works but terraform code does not.
3. Currently the resourceQuota is manually added using kubectl apply, need to add to the terraform code.
4. Try proceeding to the service deployment.

## 02/11

1. operator setup
2. check the workload

#### gpu-operator-setup

In workload, error says:

Error creating: insufficient quota to match these scopes: [{PriorityClass In [system-node-critical system-cluster-critical[]}]

According to docs from nvidia: https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/google-gke.html

A ResourceQuota shoule be created under the gpu-operator namespace

kubenetes doc: https://kubernetes.io/docs/concepts/policy/resource-quotas/#limit-priority-class-consumption-by-default

#### pod initializing forever

##### First Error: Failed to create pod sandbox

Normal Scheduled 5m9s default-scheduler Successfully assigned nvidia-gpu-operator/nvidia-operator-validator-9c7fb to gke-eyelevel-utcgge-eyelevel-gpu-rank-2891ab6f-tlvf
Warning FailedCreatePodSandBox 3s (x24 over 5m9s) kubelet Failed to create pod sandbox: rpc error: code = Unknown desc = failed to get sandbox runtime: no runtime for "nvidia" is configured

##### Possible cause: node created with gpu driver

##### possible fix: when creating the node, disable the driver install

##### Second error: image pull error

work around: directly using helm to deploy the services.

```
helm install --wait --generate-name \
    -n gpu-operator \
    nvidia/gpu-operator \
    --version=v24.9.2 \
    --set hostPaths.driverInstallDir=/home/kubernetes/bin/nvidia \
    --set toolkit.installDir=/home/kubernetes/bin/nvidia \
    --set cdi.enabled=true \
    --set cdi.default=true \
    --set driver.enabled=false
```

##### Third Error:

After fixing the above error, most pods can be deployed, remaining issues are DaemonSet has no nodes selected.
![alt text](/progress/02/11/Screenshot%202025-02-11%20at%2010.48.58 PM.png)

describe using kubectl get:

[nvidia-device-plugin-mps-control-daemon.log](/progress/02/11/nvidia-device-plugin-mps-control-daemon.log)
[nvidia-mig-manager.log](/progress/02/11/nvidia-mig-manager.log)

## 09/02/2025

### provision the vpc

### provision the gke cluster (almost)

n1+t4 is not available to the current zone. Need to specify a valid zone for this.

#### note

if terraform destroy fails and says deletion_protection is set to true.
locate the deletion project in tfstate, manually change it to false, so that terraform can delete the cluster.

## 06/02/2025

### update the gke module terraform

### update the vpc terraform code

1. what is the mapping for aws vpc private and public subnetwork?
2. how to correctly setup the secondary ip range for pods and services?
3. how to output the firewall id using the vpc module?

### TODO:

setup service account permission
setup local gcloud
modify the setup-gcp sh file.
hopefully run the bash file to see if it works -> see what quota limits need to be increased.

## 05/02/2025

### find the matched machine and image type for node pools

The min, max and desired size remain the same.

1. for cpu nodes, use general purpose machine e series
   1. cpu_memory_nodes:
      1. aws uses m6a.xlarge, 4 vcpu 16Gib mem, network bandwidth up to 12.5, ebs bandwidth up to 10.
      2. gcp uses n2-standard-4, 4 vcpu 16Gib mem, network bandwidth up to 10
   2. cpu_only_nodes:
      1. aws uses t3a.medium, 2 vcpus, 4 Gib mem, network burst bandwidth 5.
      2. gcp uses e2-standard-2: 2vcpus, 8 Gib mem, network bandwidth up to 4 -> increase vcpu 4
2. for gpu nodes,
   aws provide ami AL2023_x86_64_NVIDIA which configure the gpu driver.
   for gcp, standard machine need to configure gpu type, count, and driver version. Also need to configure gpu sharing(**need to be done**)

   1. layout_nodes:
      1. aws uses g4dn.xlarge: 1 gpu, 4 vcpus, 16 Gib mem, 16 Gib GPU mem. up to 25 network performance
      2. gcp uses n1-standard-4 with nvidia-tesla-t4(v100, p100): 1 gpu, 4 vcpus, 15 Gib mem, 16 Gib GPU mem, up to 10 network bandwidth
   2. ranker_nodes:
      1. aws uses g4dn.2xlarge: 1 gpu, 8 vcpus, 32 Gib mem, 16 Gib GPU mem. up to 25 network performance
      2. gcp uses n1-standard-8 with nvidia-tesla-t4(v100, p100): 1 gpu, 8 vcpus, 30 Gib mem, 16 Gib GPU mem, up to 10 network bandwidth
   3. summary_nodes:
      According to the document,

      The current configuration for this service assumes an NVIDIA GPU with 24 GB of GPU memory, 4 CPU cores, and at least 14 GB RAM. It deploys 2 pods on this node (called workers in operator/variables.tf) and claims the GPU via the nvidia.com/gpu resource provided by the NVIDIA GPU operator.

      g2-standard-4 is enough. But the script provision a more powerful machine.

      1. aws g6e.xlarge: 1 L40S tensor core gpu, 4 vcpus, 42 gib mem, 48 gib gpu mem, up to 20 network bandwidth
      2. gcp g2-standard-4: 1 L4 tensor core GPU, 4 vcpus, 16 gib mem, 24 gpu mem, up to 10 network bandwidth
         1. or use g2-standard-8: 1 L4 tensor core GPU, 8 vcpus, 32 gib mem, 24 gpu mem, up to 16 network bandwidth
