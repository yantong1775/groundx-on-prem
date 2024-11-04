# ENVIRONMENT

variable "environment" {
  description              = "Environment information for the Kubernetes cluster"
  type                     = object({
    cluster_role_arns      = list(object({
      arn                  = string
      name                 = string
    }))
    environment            = string
    region                 = string
    subnets                = list(string)
    ssh_key_name           = string
    vpc_id                 = string
  })
}

variable "environment_internal" {
  description         = "Environment internal settings"
  type                = object({
    eks_version       = string
  })
  default             = {
    eks_version       = "1.31"
  }
}

variable "nodes" {
  description          = "EKS compute resource information"
  type                 = object({
    node_groups        = object({
      cpu_memory_nodes = object({
        ami_type       = string
        desired_size   = number
        disk_size      = number
        instance_types = list(string)
        labels         = map(string)
        max_size       = number
        min_size       = number
        name           = string
      })
      cpu_only_nodes   = object({
        ami_type       = string
        desired_size   = number
        disk_size      = number
        instance_types = list(string)
        labels         = map(string)
        max_size       = number
        min_size       = number
        name           = string
      })
      layout_nodes     = object({
        ami_type       = string
        desired_size   = number
        disk_size      = number
        instance_types = list(string)
        labels         = map(string)
        max_size       = number
        min_size       = number
        name           = string
      })
      ranker_nodes     = object({
        ami_type       = string
        desired_size   = number
        disk_size      = number
        instance_types = list(string)
        labels         = map(string)
        max_size       = number
        min_size       = number
        name           = string
      })
      summary_nodes    = object({
        ami_type       = string
        desired_size   = number
        disk_size      = number
        instance_types = list(string)
        labels         = map(string)
        max_size       = number
        min_size       = number
        name           = string
      })
    })
  })
  default              = {
    instance_types     = ["m6g.xlarge","t4g.medium","g4dn.xlarge","g4dn.2xlarge","g5.xlarge"]
    node_groups        = {
      cpu_memory_nodes = {
        ami_type       = "AL2023_ARM_64_STANDARD"
        desired_size   = 2
        disk_size      = 75
        instance_types = ["m6g.xlarge"]
        labels         = {
          "node"       = "cpu-memory"
        }
        max_size       = 10
        min_size       = 2
        name           = "cpu-memory"
      }
      cpu_only_nodes   = {
        ami_type       = "AL2023_ARM_64_STANDARD"
        desired_size   = 3
        disk_size      = 75
        instance_types = ["t4g.medium"]
        labels         = {
          "node"       = "cpu-only"
        }
        max_size       = 10
        min_size       = 2
        name           = "cpu-only"
      }
      layout_nodes     = {
        ami_type       = "AL2023_x86_64_NVIDIA"
        desired_size   = 1
        disk_size      = 75
        instance_types = ["g4dn.xlarge"]
        labels         = {
          "node"       = "gpu-layout"
        }
        max_size       = 3
        min_size       = 1
        name           = "gpu-layout"
      }
      ranker_nodes     = {
        ami_type       = "AL2023_x86_64_NVIDIA"
        desired_size   = 2
        disk_size      = 75
        instance_types = ["g4dn.2xlarge"]
        labels         = {
          "node"       = "gpu-ranker"
        }
        max_size       = 5
        min_size       = 1
        name           = "gpu-ranker"
      }
      summary_nodes    = {
        ami_type       = "AL2023_x86_64_NVIDIA"
        desired_size   = 2
        disk_size      = 75
        instance_types = ["g5.xlarge"]
        labels         = {
          "node"       = "gpu-summary"
        }
        max_size       = 5
        min_size       = 1
        name           = "gpu-summary"
      }
    }
  }
}