# Progress

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
      2. gcp uses e2-standard-2: 2vcpus, 8 Gib mem, network bandwidth up to 4
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
