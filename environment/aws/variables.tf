# ENVIRONMENT

variable "environment" {
  description              = "Environment information for the Kubernetes cluster"
  type                     = object({
    cluster_role_arns      = list(object({
      arn                  = string
      name                 = string
    }))
    region                 = string
    security_groups        = list(string)
    ssh_key_name           = string
    stage                  = string
    subnets                = list(string)
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
  description                   = "EKS compute resource information"
  type                          = object({
    node_groups                 = object({
      cpu_memory_nodes          = object({
        ami_type                = string
        desired_size            = number
        ebs                     = object({
          delete_on_termination = bool
          encrypted             = bool
          iops                  = number
          kms_key_id            = string
          snapshot_id           = string
          throughput            = number
          volume_size           = string
          volume_type           = string
        })
        instance_types          = list(string)
        max_size                = number
        min_size                = number
      })
      cpu_only_nodes            = object({
        ami_type                = string
        desired_size            = number
        ebs                     = object({
          delete_on_termination = bool
          encrypted             = bool
          iops                  = number
          kms_key_id            = string
          snapshot_id           = string
          throughput            = number
          volume_size           = string
          volume_type           = string
        })
        instance_types          = list(string)
        max_size                = number
        min_size                = number
      })
      layout_nodes              = object({
        ami_type                = string
        desired_size            = number
        ebs                     = object({
          delete_on_termination = bool
          encrypted             = bool
          iops                  = number
          kms_key_id            = string
          snapshot_id           = string
          throughput            = number
          volume_size           = string
          volume_type           = string
        })
        instance_types          = list(string)
        max_size                = number
        min_size                = number
      })
      ranker_nodes              = object({
        ami_type                = string
        desired_size            = number
        ebs                     = object({
          delete_on_termination = bool
          encrypted             = bool
          iops                  = number
          kms_key_id            = string
          snapshot_id           = string
          throughput            = number
          volume_size           = string
          volume_type           = string
        })
        instance_types          = list(string)
        max_size                = number
        min_size                = number
      })
      summary_nodes             = object({
        ami_type                = string
        desired_size            = number
        ebs                     = object({
          delete_on_termination = bool
          encrypted             = bool
          iops                  = number
          kms_key_id            = string
          snapshot_id           = string
          throughput            = number
          volume_size           = string
          volume_type           = string
        })
        instance_types          = list(string)
        max_size                = number
        min_size                = number
      })
    })
  })
  default                       = {
    node_groups                 = {
      cpu_memory_nodes          = {
        ami_type                = "AL2023_x86_64_STANDARD"
        desired_size            = 2
        ebs                     = {
          delete_on_termination = true
          encrypted             = true
          iops                  = 3000
          kms_key_id            = null
          snapshot_id           = null
          throughput            = 125
          volume_size           = 75
          volume_type           = "gp3"
        }
        instance_types          = ["m6a.xlarge"]
        max_size                = 10
        min_size                = 1
      }
      cpu_only_nodes            = {
        ami_type                = "AL2023_x86_64_STANDARD"
        desired_size            = 3
        ebs                     = {
          delete_on_termination = true
          encrypted             = true
          iops                  = 3000
          kms_key_id            = null
          snapshot_id           = null
          throughput            = 125
          volume_size           = 75
          volume_type           = "gp3"
        }
        instance_types          = ["t3a.medium"]
        max_size                = 10
        min_size                = 1
      }
      layout_nodes              = {
        ami_type                = "AL2023_x86_64_NVIDIA"
        desired_size            = 1
        ebs                     = {
          delete_on_termination = true
          encrypted             = true
          iops                  = 3000
          kms_key_id            = null
          snapshot_id           = null
          throughput            = 125
          volume_size           = 75
          volume_type           = "gp3"
        }
        instance_types          = ["g4dn.xlarge"]
        max_size                = 5
        min_size                = 1
      }
      ranker_nodes              = {
        ami_type                = "AL2023_x86_64_NVIDIA"
        desired_size            = 3
        ebs                     = {
          delete_on_termination = true
          encrypted             = true
          iops                  = 3000
          kms_key_id            = null
          snapshot_id           = null
          throughput            = 125
          volume_size           = 75
          volume_type           = "gp3"
        }
        instance_types          = ["g4dn.2xlarge"]
        max_size                = 10
        min_size                = 1
      }
      summary_nodes             = {
        ami_type                = "AL2023_x86_64_NVIDIA"
        desired_size            = 2
        ebs                     = {
          delete_on_termination = true
          encrypted             = true
          iops                  = 3000
          kms_key_id            = null
          snapshot_id           = null
          throughput            = 125
          volume_size           = 75
          volume_type           = "gp3"
        }
        instance_types          = ["g5.xlarge"]
        max_size                = 5
        min_size                = 1
      }
    }
  }
}

variable "vpc" {
  description       = "VPC settings, for creating a VPC if needed"
  type              = object({
    cidr            = string
    private_subnets = list(string)
    public_subnets  = list(string)
  })
  default           = {
    cidr            = "10.0.0.0/16"
    private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
    public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  }
}