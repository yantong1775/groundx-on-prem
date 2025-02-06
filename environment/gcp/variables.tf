# ENVIRONMENT

variable "environment" {
  description = "Environment information for the Kubernetes cluster"
  type = object({
    cluster_role_arns = list(object({
      arn  = string
      name = string
    }))
    project_id = string
    region          = string
    zones = list(string)
    security_groups = list(string)
    ssh_key_name    = string
    stage           = string
    subnets         = list(string)
    vpc_id          = string
  })
}

variable "environment_internal" {
  description = "Environment internal settings"
  type = object({
    eks_version = string
  })
  default = {
    eks_version = "1.31"
  }
}

variable "autoscaler_internal" {
  type = object({
    chart = object({
      name       = string
      repository = string
      version    = string
    })
    resources = object({
      limits = object({
        cpu    = number
        memory = string
      })
      requests = object({
        cpu    = number
        memory = string
      })
    })
  })
  default = {
    chart = {
      name       = "cluster-autoscaler"
      repository = "https://kubernetes.github.io/autoscaler"
      version    = "9.29.0"
    }
    resources = {
      limits = {
        cpu    = 0.2
        memory = "512Mi"
      }
      requests = {
        cpu    = 0.1
        memory = "256Mi"
      }
    }
  }
}

variable "nodes" {
  description = "GKE compute resource information"
  type = object({
    node_groups = object({
      cpu_memory_nodes = object({
        name         = string
        machine_type     = string # aws instance_type
        image_type = string # aws ami_type
        min_count       = number # aws min_size
        max_count       = number # aws max_size
        node_count     = number # aws desired_size

        disk_size_gb    = number # aws ebs
        disk_type       = string
      })
      cpu_only_nodes = object({
        name         = string
        machine_type     = string
        image_type = string
        min_count       = number
        max_count       = number

        disk_size_gb    = number
        disk_type       = string
      })
      layout_nodes = object({
        name         = string
        machine_type     = string
        image_type = string
        min_count       = number
        max_count       = number

        disk_size_gb    = number
        disk_type       = string

        gpu_driver_version = string
        accelerator_count  = number
        accelerator_type   = string

        #gpu_sharing_strategy        = string
        #max_shared_clients_per_gpu = number
      })
      ranker_nodes = object({
        name         = string
        machine_type     = string
        image_type = string
        min_count       = number
        max_count       = number

        disk_size_gb    = number
        disk_type       = string

        gpu_driver_version = string
        accelerator_count  = number
        accelerator_type   = string

        #gpu_sharing_strategy        = string
        #max_shared_clients_per_gpu = number
      })
      summary_nodes = object({
        name         = string
        machine_type     = string
        image_type = string
        min_count       = number
        max_count       = number

        disk_size_gb    = number
        disk_type       = string

        gpu_driver_version = string
        accelerator_count  = number
        accelerator_type   = string

        #gpu_sharing_strategy        = string
        #max_shared_clients_per_gpu = number
      })
    })
  })
  default = {
    node_groups = {
      cpu_memory_nodes = {
        name        = "cpu_memory_nodes"
        machine_type = "n2-standard-4" # 4 vCPUs, 16 GB memory, Up to 10 Gbps network bandwidth
        image_type = "cos-117-lts" # x86 family Container Optimized OS
        min_count = 1
        max_count = 4
        node_count = 1

        disk_size_gb = 20
        disk_type    = "pd-balanced" # 15,000 IOPS and 240 MiBps max throughput
      }
      cpu_only_nodes = {
        name        = "cpu_only_nodes"
        machine_type = "e2-standard-2" # 2 vCPUs, 8 GB memory
        image_type = "cos-117-lts" # x86 family Container Optimized OS
        min_count = 3
        max_count = 15
        node_count = 3

        disk_size_gb = 20
        disk_type    = "pd-balanced" # 15,000 IOPS and 240 MiBps max throughput
      }
      layout_nodes = {
        name        = "layout_nodes"
        machine_type = "n1-standard-4" # 4 vCPUs, 15 GB memory
        image_type = "cos-117-lts" # x86 family Container Optimized OS
        min_count = 1
        max_count = 5
        node_count = 1

        disk_size_gb = 35
        disk_type    = "pd-balanced" # 15,000 IOPS and 240 MiBps max throughput

        accelerator_count  = 1
        accelerator_type   = "nvidia-tesla-t4" # 16 GB GPU memory, v100 p100 are also available
        gpu_driver_version = "LATEST"
      }
      ranker_nodes = {
        name        = "layout_nodes"
        machine_type = "n1-standard-8" # 8 vCPUs, 30 GB memory !!! need to be confirmed.
        image_type = "cos-117-lts" # x86 family Container Optimized OS
        min_count = 1
        max_count = 10
        node_count = 1

        disk_size_gb = 75
        disk_type    = "pd-balanced" # 15,000 IOPS and 240 MiBps max throughput

        accelerator_count  = 1
        accelerator_type   = "nvidia-tesla-t4" # 16 GB GPU memory, v100 p100 are also available
        gpu_driver_version = "LATEST"
      }
      summary_nodes = {
        name        = "layout_nodes"
        machine_type = "g2-standard-4" # 4 vCPUs, 24 GB memory !!! need to be confirmed.
        image_type = "cos-117-lts" # x86 family Container Optimized OS
        min_count = 1
        max_count = 10
        node_count = 1

        disk_size_gb = 75
        disk_type    = "pd-balanced" # 15,000 IOPS and 240 MiBps max throughput

        accelerator_count  = 1
        gpu_driver_version = "LATEST"
      }
    }
  }
}

variable "vpc" {
  description = "VPC settings, for creating a VPC if needed"
  type = object({
    cidr            = string
    private_subnets = list(string)
    public_subnets  = list(string)
  })
  default = {
    cidr            = "10.0.0.0/16"
    private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
    public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  }
}