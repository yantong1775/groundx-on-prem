# CLUSTER

variable "cluster" {
  description = "Information about the Kubernetes cluster"
  type        = object({
    # has external internet access
    internet_access  = bool

    kube_config_path = string
    name             = string

    # admin or developer
    role             = string
    type             = string
  })
  default = {
    internet_access  = true
    kube_config_path = "~/.kube/config"
    name             = "eyelevel"
    role             = "admin"
    type             = "eks"
  }
  validation {
    condition        = var.cluster.role == "admin"
    error_message    = "You must be an admin of this cluster to install the operator"
  }
}

variable "cluster_internal" {
  description = "Kubernetes cluster internal settings"
  type        = object({
    nodes     = object({
      cpu_only    = string
      cpu_memory  = string
      gpu_layout  = string
      gpu_ranker  = string
      gpu_summary = string
    })
  })
  default = {
    nodes = {
      cpu_only    = "cpu-only"
      cpu_memory  = "cpu-memory"
      gpu_layout  = "gpu-layout"
      gpu_ranker  = "gpu-ranker"
      gpu_summary = "gpu-summary"
    }
  }
}