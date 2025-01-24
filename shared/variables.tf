# THROUGHPUT

variable "throughput" {
  description         = "Baseline and max throughputs for services, in tokens per minute"
  type                = object({
    conversions       = object({
      document        = object({
        tpm           = number
      })
      page            = object({
        tpm           = number
      })
      summaryRequests = object({
        tpm           = number
      })
    })
    ingest            = object({
      baseline        = number
      max             = number
    })
    search            = object({
      baseline        = number
      max             = number
    })
    services          = object({
      layout          = object({
        inference     = number
        map           = number
        ocr           = number
        process       = number
        save          = number
      })
      pre_process     = object({
        queue         = number
      })
      process         = object({
        queue         = number
      })
      queue           = object({
        queue         = number
      })
      ranker          = object({
        inference     = number
      })
      summary         = object({
        api           = number
        inference     = number
      })
      summary_client  = object({
        api           = number
      })
      upload          = object({
        queue         = number
      })
    })
  })
  default             = {
    conversions       = {
      document        = {
        tpm           = 12500
      }
      page            = {
        tpm           = 500
      }
      summaryRequests = {
        tpm           = 625
      }
    }
    ingest            = {
      baseline        = 9600
      max             = 25000
    }
    search            = {
      baseline        = 400000
      max             = 3600000
    }
    services          = {
      layout          = {
        inference     = 240 * 500
        map           = 500
        ocr           = 500
        process       = 500
        save          = 500
      }
      pre_process     = {
        queue         = 6
      }
      process     = {
        queue         = 9
      }
      queue       = {
        queue         = 9
      }
      ranker          = {
        inference     = 0
      }
      summary         = {
        api           = 9600
        inference     = 3200
      }
      summary_client  = {
        api           = 9600
      }
      upload          = {
        queue         = 120
      }
    }
  }
}

# CLUSTER

variable "cluster" {
  description = "Information about the Kubernetes cluster"
  type        = object({
    # hosting environment
    # valid values: aws, self
    environment      = string

    # set to true if the NVIDIA operator is already installed
    has_nvidia       = bool

    # has external internet access
    internet_access  = bool

    kube_config_path = string

    # used on resource names
    prefix           = string

    # admin or developer
    role             = string

    # whether search service should be deployed or not
    search           = bool

    # type of Kubernetes cluster
    # valid values: eks, openshift
    type             = string
  })
  default = {
    environment      = "aws"
    has_nvidia       = false
    internet_access  = true
    kube_config_path = "~/.kube/config"
    prefix           = "eyelevel"
    role             = "admin"
    search           = true
    type             = "eks"
  }
  validation {
    condition        = var.cluster.role == "admin"
    error_message    = "You must be an admin of this cluster to install the operator"
  }
}

variable "cluster_internal" {
  description      = "Kubernetes cluster internal settings"
  type             = object({
    autoscale      = bool
    nodes          = object({
      cpu_memory   = string
      cpu_only     = string
      gpu_layout   = string
      gpu_ranker   = string
      gpu_summary  = string
    })
    nvidia         = object({
      driver       = string
      name         = string
      namespace    = string
      chart        = object({
        name       = string
        repository = string
        version    = string
      })
    })
    pv             = object({
      name         = string
      type         = string
    })
  })
  default          = {
    autoscale      = false
    nodes          = {
      cpu_memory   = "eyelevel-cpu-memory"
      cpu_only     = "eyelevel-cpu-only"
      gpu_layout   = "eyelevel-gpu-layout"
      gpu_ranker   = "eyelevel-gpu-ranker"
      gpu_summary  = "eyelevel-gpu-summary"
    }
    nvidia         = {
      driver       = "550.54.15"
      name         = "nvidia-gpu-operator"
      namespace    = "nvidia-gpu-operator"
      chart        = {
        name       = "gpu-operator"
        repository = "https://helm.ngc.nvidia.com/nvidia"
        version    = "v23.9.2"
      }
    }
    pv             = {
      name         = "eyelevel-ebs-gp2"
      type         = "gp2"
    }
  }
}


# CACHE

variable "cache_resources" {
  description  = "Cache compute resource information"
  type         = object({
    metrics    = bool
    node       = string
    replicas   = number
    resources  = object({
      limits   = object({
        cpu    = number
        memory = string
      })
      requests = object({
        cpu    = number
        memory = string
      })
    })
  })
  default      = {
    metrics    = true
    node       = "eyelevel-cpu-only"
    replicas   = 1
    resources  = {
      limits   = {
        cpu    = 3
        memory = "12Gi"
      }
      requests = {
        cpu    = 0.2
        memory = "512Mi"
      }
    }
  }
}


# DATABASE

variable "db_resources" {
  description    = "Database compute resource information"
  type           = object({
    node         = string
    proxy        = object({
      node       = string
      replicas   = number
      resources  = object({
        limits   = object({
          cpu    = number
          memory = string
        })
        requests = object({
          cpu    = number
          memory = string
        })
      })
    })
    pv_size      = string
    replicas     = number
    resources    = object({
      limits     = object({
        cpu      = number
        memory   = string
      })
      requests   = object({
        cpu      = number
        memory   = string
      })
    })
  })
  default        = {
    node         = "eyelevel-cpu-only"
    proxy        = {
      node       = "eyelevel-cpu-only"
      replicas   = 1
      resources  = {
        limits   = {
          cpu    = 3
          memory = "12Gi"
        }
        requests = {
          cpu    = 0.2
          memory = "512Mi"
        }
      }
    }
    pv_size      = "20Gi"
    replicas     = 1
    resources    = {
      limits     = {
        cpu      = 3
        memory   = "12Gi"
      }
      requests   = {
        cpu      = 0.75
        memory   = "1Gi"
      }
    }
  }
}


# FILE

variable "file_resources" {
  description           = "Database compute resource information"
  type                  = object({
    node                = string
    operator            = object({
      replicas          = number
    })
    pool_size           = string
    pool_servers        = number
    pool_server_volumes = number
    pv_path             = string
    resources           = object({
      limits            = object({
        cpu             = number
        memory          = string
      })
      requests          = object({
        cpu             = number
        memory          = string
      })
    })
    ssl                 = bool
  })
  default               = {
    node                = "eyelevel-cpu-only"
    operator            = {
      replicas          = 1
    }
    pool_size           = "50Gi"
    pool_servers        = 1
    pool_server_volumes = 1
    pv_path             = "/Users/USER/mnt/minio"
    resources           = {
      limits            = {
        cpu             = 3
        memory          = "12Gi"
      }
      requests          = {
        cpu             = 0.2
        memory          = "512Mi"
      }
    }
    ssl                 = false
  }
}


# GRAPH

variable "graph_resources" {
  description  = "Graph compute resource information"
  type         = object({
    node       = string
    replicas   = number
    resources  = object({
      limits   = object({
        cpu    = number
        memory = string
      })
      requests = object({
        cpu    = number
        memory = string
      })
    })
  })
  default      = {
    node       = "eyelevel-cpu-only"
    replicas   = 1
    resources  = {
      limits   = {
        cpu    = 3
        memory = "12Gi"
      }
      requests = {
        cpu    = 0.2
        memory = "512Mi"
      }
    }
  }
}


# GROUNDX

variable "groundx_resources" {
  description   = "GroundX compute resource information"
  type          = object({
    node        = string
    replicas    = object({
      cooldown  = number
      threshold = number
    })
    resources   = object({
      limits    = object({
        cpu     = number
        memory  = string
      })
      requests  = object({
        cpu     = number
        memory  = string
      })
    })
    throughput  = number
  })
  default       = {
    node        = "eyelevel-cpu-only"
    replicas    = {
      cooldown  = 60
      threshold = 8
    }
    resources   = {
      limits    = {
        cpu     = 2
        memory  = "4Gi"
      }
      requests  = {
        cpu     = 0.1
        memory  = "128Mi"
      }
    }
    throughput  = 150000
  }
}


# LAYOUT

variable "layout_resources" {
  description     = "Layout compute resource information"
  type            = object({
    api           = object({
      node        = string
      replicas    = object({
        cooldown  = number
        threshold = number
      })
      resources   = object({
        limits    = object({
          cpu     = number
          memory  = string
        })
        requests  = object({
          cpu     = number
          memory  = string
        })
      })
      threads     = number
      throughput  = number
      workers     = number
    })
    inference     = object({
      node        = string
      replicas    = object({
        cooldown  = number
        threshold = number
      })
      resources   = object({
        limits    = object({
          cpu     = number
          memory  = string
          gpu     = number
        })
        requests  = object({
          cpu     = number
          memory  = string
          gpu     = number
        })
      })
      threads     = number
      throughput  = number
      workers     = number
    })
    load_balancer = object({
      internal    = bool
      port        = number
    })
    map           = object({
      node        = string
      replicas    = object({
        cooldown  = number
        threshold = number
      })
      resources   = object({
        limits    = object({
          cpu     = number
          memory  = string
        })
        requests  = object({
          cpu     = number
          memory  = string
        })
      })
      threads     = number
      throughput  = number
      workers     = number
    })
    ocr           = object({
      node        = string
      replicas    = object({
        cooldown  = number
        threshold = number
      })
      resources   = object({
        limits    = object({
          cpu     = number
          memory  = string
        })
        requests  = object({
          cpu     = number
          memory  = string
        })
      })
      threads     = number
      throughput  = number
      workers     = number
    })
    process       = object({
      node        = string
      replicas    = object({
        cooldown  = number
        threshold = number
      })
      resources   = object({
        limits    = object({
          cpu     = number
          memory  = string
        })
        requests  = object({
          cpu     = number
          memory  = string
        })
      })
      threads     = number
      throughput  = number
      workers     = number
    })
    save          = object({
      node        = string
      replicas    = object({
        cooldown  = number
        threshold = number
      })
      resources   = object({
        limits    = object({
          cpu     = number
          memory  = string
        })
        requests  = object({
          cpu     = number
          memory  = string
        })
      })
      threads     = number
      throughput  = number
      workers     = number
    })
  })
  default         = {
    api           = {
      node        = "eyelevel-cpu-only"
      replicas    = {
        cooldown  = 60
        threshold = 5
      }
      resources   = {
        limits    = {
          cpu     = 2
          memory  = "4Gi"
        }
        requests  = {
          cpu     = 0.1
          memory  = "128Mi"
        }
      }
      threads     = 2
      throughput  = 150000
      workers     = 2
    }
    inference     = {
      node        = "eyelevel-gpu-layout"
      replicas    = {
        cooldown  = 60
        threshold = 0.8
      }
      resources   = {
        limits    = {
          cpu     = 2
          memory  = "6Gi"
          gpu     = 1
        }
        requests  = {
          cpu     = 1
          memory  = "2Gi"
          gpu     = 1
        }
      }
      threads     = 2
      throughput  = 120000
      workers     = 4
    }
    load_balancer = {
      internal    = true
      port        = 80
    }
    map           = {
      node        = "eyelevel-cpu-only"
      replicas    = {
        cooldown  = 60
        threshold = 0.8
      }
      resources   = {
        limits    = {
          cpu     = 2
          memory  = "12Gi"
        }
        requests  = {
          cpu     = 0.1
          memory  = "256Mi"
        }
      }
      threads     = 1
      throughput  = 300000
      workers     = 1
    }
    ocr           = {
      node        = "eyelevel-cpu-memory"
      replicas    = {
        cooldown  = 60
        threshold = 0.8
      }
      resources   = {
        limits    = {
          cpu     = 4
          memory  = "16Gi"
        }
        requests  = {
          cpu     = 3
          memory  = "1Gi"
        }
      }
      threads     = 1
      throughput  = 10000
      workers     = 1
    }
    process       = {
      node        = "eyelevel-cpu-only"
      replicas    = {
        cooldown  = 60
        threshold = 0.8
      }
      resources   = {
        limits    = {
          cpu     = 2
          memory  = "12Gi"
        }
        requests  = {
          cpu     = 0.1
          memory  = "256Mi"
        }
      }
      threads     = 1
      throughput  = 300000
      workers     = 1
    }
    save          = {
      node        = "eyelevel-cpu-only"
      replicas    = {
        cooldown  = 60
        threshold = 0.8
      }
      resources   = {
        limits    = {
          cpu     = 2
          memory  = "12Gi"
        }
        requests  = {
          cpu     = 0.2
          memory  = "256Mi"
        }
      }
      threads     = 1
      throughput  = 300000
      workers     = 1
    }
  }
}


# LAYOUT WEBHOOK

variable "layout_webhook_resources" {
  description   = "Layout webhook compute resource information"
  type          = object({
    load_balancer = object({
      internal    = bool
      port        = number
    })
    node        = string
    replicas    = object({
      cooldown  = number
      threshold = number
    })
    resources   = object({
      limits    = object({
        cpu     = number
        memory  = string
      })
      requests  = object({
        cpu     = number
        memory  = string
      })
    })
    throughput  = number
  })
  default       = {
    load_balancer = {
      internal    = true
      port        = 80
    }
    node        = "eyelevel-cpu-only"
    replicas    = {
      cooldown  = 60
      threshold = 5
    }
    resources   = {
      limits    = {
        cpu     = 2
        memory  = "4Gi"
      }
      requests  = {
        cpu     = 0.1
        memory  = "128Mi"
      }
    }
    throughput  = 1250000
  }
}


# METRICS

variable "metrics_resources" {
  description   = "Metrics compute resource information"
  type          = object({
    node        = string
  })
  default       = {
    node        = "eyelevel-cpu-only"
  }
}


# PRE-PROCESS

variable "pre_process_resources" {
  description   = "Pre-Process compute resource information"
  type          = object({
    node        = string
    queue_size  = number
    replicas    = object({
      cooldown  = number
      threshold = number
    })
    resources   = object({
      limits    = object({
        cpu     = number
        memory  = string
      })
      requests  = object({
        cpu     = number
        memory  = string
      })
    })
    throughput  = number
  })
  default       = {
    node        = "eyelevel-cpu-memory"
    queue_size  = 4
    replicas    = {
      cooldown  = 60
      threshold = 0.8
    }
    resources   = {
      limits    = {
        cpu     = 3
        memory  = "12Gi"
      }
      requests  = {
        cpu     = 0.2
        memory  = "512Mi"
      }
    }
    throughput  = 9600
  }
}


# PROCESS

variable "process_resources" {
  description   = "Process compute resource information"
  type          = object({
    node        = string
    queue_size  = number
    replicas    = object({
      cooldown  = number
      threshold = number
    })
    resources   = object({
      limits    = object({
        cpu     = number
        memory  = string
      })
      requests  = object({
        cpu     = number
        memory  = string
      })
    })
    throughput  = number
  })
  default       = {
    node        = "eyelevel-cpu-only"
    queue_size  = 4
    replicas    = {
      cooldown  = 60
      threshold = 0.8
    }
    resources   = {
      limits    = {
        cpu     = 2
        memory  = "12Gi"
      }
      requests  = {
        cpu     = 0.2
        memory  = "256Mi"
      }
    }
    throughput  = 11250
  }
}


# QUEUE

variable "queue_resources" {
  description   = "Queue compute resource information"
  type          = object({
    node        = string
    queue_size  = number
    replicas    = object({
      cooldown  = number
      threshold = number
    })
    resources   = object({
      limits    = object({
        cpu     = number
        memory  = string
      })
      requests  = object({
        cpu     = number
        memory  = string
      })
    })
    throughput  = number
  })
  default       = {
    node        = "eyelevel-cpu-only"
    queue_size  = 4
    replicas    = {
      cooldown  = 60
      threshold = 0.8
    }
    resources   = {
      limits    = {
        cpu     = 2
        memory  = "12Gi"
      }
      requests  = {
        cpu     = 0.1
        memory  = "128Mi"
      }
    }
    throughput  = 11250
  }
}


# RANKER



variable "ranker_resources" {
  description     = "Ranker compute resource information"
  type            = object({
    api           = object({
      node        = string
      replicas    = object({
        cooldown  = number
        threshold = number
      })
      resources   = object({
        limits    = object({
          cpu     = number
          memory  = string
        })
        requests  = object({
          cpu     = number
          memory  = string
        })
      })
      threads     = number
      throughput  = number
      workers     = number
    })
    inference     = object({
      node        = string
      replicas    = object({
        cooldown  = number
        threshold = number
      })
      resources   = object({
        limits    = object({
          cpu     = number
          memory  = string
          gpu     = number
        })
        requests  = object({
          cpu     = number
          memory  = string
          gpu     = number
        })
      })
      throughput  = number
      workers     = number
    })
  })
  default         = {
    api           = {
      node        = "eyelevel-cpu-only"
      replicas    = {
        cooldown  = 60
        threshold = 5
      }
      resources   = {
        limits    = {
          cpu     = 2
          memory  = "4Gi"
        }
        requests  = {
          cpu     = 0.1
          memory  = "128Mi"
        }
      }
      threads     = 3
      throughput  = 1000000
      workers     = 1
    }
    inference     = {
      node        = "eyelevel-gpu-ranker"
      replicas    = {
        cooldown  = 60
        threshold = 0.8
      }
      resources   = {
        limits    = {
          cpu     = 8
          memory  = "36Gi"
          gpu     = 1
        }
        requests  = {
          cpu     = 6
          memory  = "12Gi"
          gpu     = 1
        }
      }
      throughput  = 400000
      workers     = 14
    }
  }
}


# SEARCH

variable "search_resources" {
  description     = "Search compute resource information"
  type            = object({
    node          = string
    pv_size       = string
    replicas      = number
    resources     = object({
      limits    = object({
        cpu       = number
        memory    = string
      })
      requests    = object({
        cpu       = number
        memory    = string
      })
    })
  })
  default         = {
    node          = "eyelevel-cpu-only"
    pv_size       = "20Gi"
    replicas      = 1
    resources     = {
      limits    = {
        cpu       = 3
        memory    = "12Gi"
      }
      requests    = {
        cpu       = 0.2
        memory    = "512Mi"
      }
    }
  }
}


# STREAM

variable "stream_resources" {
  description       = "Stream compute resource information"
  type              = object({
    node            = string
    operator        = object({
      replicas      = number
    })
    resources       = object({
      limits        = object({
        cpu         = number
        memory      = string
      })
      requests      = object({
        cpu         = number
        memory      = string
      })
    })
    retention_bytes = number
    segment_bytes   = number
    service         = object({
      replicas      = number
      storage       = string
    })
    zookeeper       = object({
      replicas      = number
      storage       = string
    })
  })
  default           = {
    node            = "eyelevel-cpu-only"
    operator        = {
      replicas      = 1
    }
    resources       = {
      limits        = {
        cpu         = 3
        memory      = "12Gi"
      }
      requests      = {
        cpu         = 0.2
        memory      = "512Mi"
      }
    }
    retention_bytes = 1073741824
    segment_bytes   = 1073741824
    service         = {
      replicas      = 2
      storage       = "10Gi"
    }
    zookeeper       = {
      replicas      = 1
      storage       = "5Gi"
    }
  }
}


# SUMMARY

variable "summary_resources" {
  description     = "Summary compute resource information"
  type            = object({
    api           = object({
      node        = string
      replicas    = object({
        cooldown  = number
        threshold = number
      })
      resources   = object({
        limits    = object({
          cpu     = number
          memory  = string
        })
        requests  = object({
          cpu     = number
          memory  = string
        })
      })
      threads     = number
      throughput  = number
      workers     = number
    })
    inference     = object({
      node        = string
      replicas    = object({
        cooldown  = number
        threshold = number
      })
      resources   = object({
        limits    = object({
          cpu     = number
          memory  = string
          gpu     = number
        })
        requests  = object({
          cpu     = number
          memory  = string
          gpu     = number
        })
      })
      threads     = number
      throughput  = number
      workers     = number
    })
    load_balancer = object({
      internal    = bool
      port        = number
    })
  })
  default         = {
    api           = {
      node        = "eyelevel-cpu-only"
      replicas    = {
        cooldown  = 60
        threshold = 0.8
      }
      resources   = {
        limits    = {
          cpu     = 3
          memory  = "12Gi"
        }
        requests  = {
          cpu     = 0.1
          memory  = "256Mi"
        }
      }
      threads     = 4
      throughput  = 9600
      workers     = 1
    }
    inference     = {
      node        = "eyelevel-gpu-summary"
      replicas    = {
        cooldown  = 60
        threshold = 0.8
      }
      resources   = {
        limits    = {
          cpu     = 4
          memory  = "32Gi"
          gpu     = 1
        }
        requests  = {
          cpu     = 1
          memory  = "6Gi"
          gpu     = 1
        }
      }
      threads     = 1
      throughput  = 4800
      workers     = 1
    }
    load_balancer = {
      internal    = true
      port        = 80
    }
  }
}


# SUMMARY-CLIENT

variable "summary_client_resources" {
  description   = "Summary client compute resource information"
  type          = object({
    node        = string
    replicas    = object({
      cooldown  = number
      threshold = number
    })
    resources   = object({
      limits    = object({
        cpu     = number
        memory  = string
      })
      requests  = object({
        cpu     = number
        memory  = string
      })
    })
    throughput  = number
    workers     = number
  })
  default       = {
    node        = "eyelevel-cpu-only"
    replicas    = {
      cooldown  = 60
      threshold = 0.8
    }
    resources   = {
      limits    = {
        cpu     = 3
        memory  = "12Gi"
      }
      requests  = {
        cpu     = 0.1
        memory  = "256Mi"
      }
    }
    throughput  = 9600
    workers     = 3
  }
}


# UPLOAD

variable "upload_resources" {
  description   = "Upload compute resource information"
  type          = object({
    node        = string
    queue_size  = number
    replicas    = object({
      cooldown  = number
      threshold = number
    })
    resources   = object({
      limits    = object({
        cpu     = number
        memory  = string
      })
      requests  = object({
        cpu     = number
        memory  = string
      })
    })
    throughput  = number
  })
  default       = {
    node        = "eyelevel-cpu-only"
    queue_size  = 4
    replicas    = {
      cooldown  = 60
      threshold = 0.8
    }
    resources   = {
      limits    = {
        cpu     = 2
        memory  = "4Gi"
      }
      requests  = {
        cpu     = 0.1
        memory  = "128Mi"
      }
    }
    throughput  = 150000
  }
}