# GLOBALS

variable "admin" {
  description = "Administrator account information for EyeLevel"
  type        = object({
    # should be a UUID, generate using uuid.sh
    api_key   = string

    email     = string
    password  = string

    # should be a UUID, generate using uuid.sh
    username  = string
  })
}

variable "app" {
  description = "EyeLevel application information"
  type        = object({
    namespace = string
    pv_class  = string
  })
  default = {
    namespace = "eyelevel"
    pv_class  = "empty"
  }
}


# CLUSTER

variable "cluster" {
  description = "Information about the Kubernetes cluster"
  type        = object({
    # has external internet access
    internet_access  = bool

    kube_config_path = string

    # admin or developer
    role             = string
    type             = string
  })
  default = {
    internet_access  = true
    kube_config_path = "~/.kube/config"
    role             = "admin"
    type             = "openshift"
  }
  validation {
    condition        = var.cluster.role == "admin"
    error_message    = "You must be an admin of this OpenShift cluster to install the operator"
  }
}


# CACHE

variable "cache_existing" {
  description    = "Cache settings, if using an existing Redis cache outside of Kubernetes"
  type           = object({
    addr         = string
    is_instance  = bool
    port         = number
  })
  default        = {
    addr         = null
    is_instance  = null
    port         = null
  }
}

variable "cache_internal" {
  description        = "Redis internal settings"
  type               = object({
    image            = object({
      pull           = string
      repository     = string
      tag            = string
    })
    is_instance      = bool
    mount_path       = string
    node             = string
    operator_version = string
    port             = number
    service          = string
    version          = string
  })
  default            = {
    image            = {
      pull           = "Always"
      repository     = "public.ecr.aws/c9r4x6y5/eyelevel/redis"
      tag            = "latest"
    }
    is_instance      = true
    mount_path       = "/mnt/redis"
    node             = "cpu"
    operator_version = "v7.4.6-2"
    port             = 6379
    service          = "redis"
    version          = "6.1"
  }
}

variable "cache_resources" {
  description  = "Cache compute resource information"
  type         = object({
    replicas   = number
    resources  = object({
      limits   = object({
        cpu    = string
        memory = string
      })
      requests = object({
        cpu    = string
        memory = string
      })
    })
  })
  default      = {
    replicas   = 3
    resources  = {
      limits   = {
        cpu    = "2"
        memory = "16Gi"
      }
      requests = {
        cpu    = "2"
        memory = "16Gi"
      }
    }
  }
}


# DASHBOARD

variable "dashboard_internal" {
  description = "Web dashboard internal settings"
  type        = object({
    node      = string
    service   = string
  })
  default     = {
    node      = "cpu"
    service   = "dashboard"
  }
}


# DATABASE

variable "db" {
  description        = "Database service information"
  type               = object({
    db_name          = string
    db_password      = string
    db_root_password = string
    db_username      = string
  })
  default            = {
    db_name          = "eyelevel"
    db_password      = "password"
    db_root_password = "password"
    db_username      = "eyelevel"
  }
}

variable "db_existing" {
  description = "Database endpoint settings, if using an existing database outside of Kubernetes"
  type        = object({
    port      = number
    ro        = string
    rw        = string
  })
  default     = {
    port      = null
    ro        = null
    rw        = null
  }
}

variable "db_internal" {
  description             = "Database internal settings"
  type                    = object({
    backup                = bool
    chart                 = object({
      base                = string
      db                  = string
      operator            = string
      repository          = string
    })
    disable_unsafe_checks = bool
    ip_type               = string
    logcollector_enable   = bool
    node                  = string
    pmm_enable            = bool
    port                  = number
    service               = string
    version               = string
  })
  default                 = {
    backup                = true
    chart                 = {
      base                = "percona"
      db                  = "percona/pxc-db"
      operator            = "percona/pxc-operator"
      repository          = "https://percona.github.io/percona-helm-charts"
    }
    disable_unsafe_checks = false
    ip_type               = "ClusterIP"
    logcollector_enable   = true
    node                  = "cpu"
    pmm_enable            = false
    port                  = 3306
    service               = "mysql"
    version               = "8.0"
  }
}

variable "db_resources" {
  description    = "Database compute resource information"
  type           = object({
    proxy        = object({
      replicas   = number
      resources  = object({
        limits   = object({
          cpu    = string
          memory = string
        })
        requests = object({
          cpu    = string
          memory = string
        })
      })
    })
    pv_size      = string
    replicas     = number
    resources    = object({
      limits     = object({
        cpu      = string
        memory   = string
      })
      requests   = object({
        cpu      = string
        memory   = string
      })
    })
  })
  default        = {
    proxy        = {
      replicas   = 3
      resources  = {
        limits   = {
          cpu    = "600m"
          memory = "1Gi"
        }
        requests = {
          cpu    = "600m"
          memory = "1Gi"
        }
      }
    }
    pv_size      = "20Gi"
    replicas     = 3
    resources    = {
      limits     = {
        cpu      = "600m"
        memory   = "1Gi"
      }
      requests   = {
        cpu      = "600m"
        memory   = "1Gi"
      }
    }
  }
}


# FILE

variable "file" {
  description     = "Database service information"
  type            = object({
    password      = string
    upload_bucket = string
    username      = string
  })
  default         = {
    password      = "minio123"
    upload_bucket = "eyelevel"
    username      = "minio"
  }
}

variable "file_existing" {
  description   = "MinIO settings, if using an existing MinIO instance outside of Kubernetes"
  type          = object({
    # no protocol
    base_domain = string

    bucket      = string
    password    = string
    port        = number
    ssl         = bool
    username    = string
  })
  default      = {
    base_domain = null
    bucket      = null
    password    = null
    port        = null
    ssl         = null
    username    = null
  }
}

variable "file_internal" {
  description        = "Database internal settings"
  type               = object({
    chart_base       = string
    chart_repository = string
    node             = string
    operator         = object({
      chart          = string
      chart_version  = string
    })
    port             = number
    pv_access        = string
    service          = string
    tenant           = object({
      chart          = string
      chart_version  = string
    })
    version          = string
  })
  default            = {
    chart_base       = "minio-operator"
    chart_repository = "https://operator.min.io"
    node             = "cpu"
    operator         = {
      chart          = "minio-operator/operator"
      chart_version  = "6.0.3"
    }
    port             = 9000
    pv_access        = "ReadWriteMany"
    service          = "minio"
    tenant           = {
      chart          = "minio-operator/tenant"
      chart_version  = "6.0.3"
    }
    version          = "6.0.3"
  }
}

variable "file_resources" {
  description           = "Database compute resource information"
  type                  = object({
    operator            = object({
      replicas          = number
    })
    pool_size           = string
    pool_servers        = number
    pool_server_volumes = number
    pv_path             = string
    resources           = object({
      limits            = object({
        cpu             = string
        memory          = string
      })
      requests          = object({
        cpu             = string
        memory          = string
      })
    })
    ssl                 = bool
  })
  default               = {
    operator            = {
      replicas          = 2
    }
    pool_size           = "1Ti"
    pool_servers        = 4
    pool_server_volumes = 4
    pv_path             = "/Users/USER/mnt/minio"
    resources           = {
      limits            = {
        cpu             = "4"
        memory          = "8Gi"
      }
      requests          = {
        cpu             = "2"
        memory          = "4Gi"
      }
    }
    ssl                 = false
  }
}


# GROUNDX

variable "groundx" {
  description     = "GroundX service information"
  type            = object({
    load_balancer = object({
      port        = number
    })
  })
  default         = {
    load_balancer = {
      port        = 80
    }
  }
}

variable "groundx_internal" {
  description    = "GroundX internal settings"
  type           = object({
    image        = object({
      pull       = string
      repository = string
      tag        = string
    })
    node         = string
    service      = string
    # all or search
    type         = string
    version      = string
  })
  default        = {
    image        = {
      pull       = "Always"
      repository = "public.ecr.aws/c9r4x6y5/eyelevel/groundx"
      tag        = "latest"
    }
    node         = "cpu"
    service      = "groundx"
    type         = "all"
    version      = "0.0.1"
  }
}


# LAYOUT

variable "layout" {
  type            = object({
    ocr           = object({
      credentials   = string
      project       = string
      type          = string
    })
  })
  default         = {
    ocr           = {
      credentials   = "gcv_credentials.json"
      project       = ""
      type          = "google"
    }
  }
  validation {
    condition     = var.layout.ocr.type != "google" || var.layout.ocr.project != ""
    error_message = "Project must be set if using Google OCR"
  }
}

variable "layout_internal" {
  description    = "Layout internal settings"
  type           = object({
    api            = object({
      image        = object({
        pull       = string
        repository = string
        tag        = string
      })
    })
    inference      = object({
      image        = object({
        pull       = string
        repository = string
        tag        = string
      })
      image_op     = object({
        pull       = string
        repository = string
        tag        = string
      })
    })
    models         = object({
      device     = string
      figure       = object({
        name       = string
        pth        = string
        yml        = string
      })
      table        = object({
        name       = string
        pth        = string
        yml        = string
      })
    })
    nodes          = object({
      api          = string
      inference    = string
      ocr          = string
      process      = string
    })
    process        = object({
      image        = object({
        pull       = string
        repository = string
        tag        = string
      })
    })
    service        = string
    version        = string
  })
  default          = {
    api            = {
      image        = {
        pull       = "Always"
        repository = "public.ecr.aws/c9r4x6y5/eyelevel/python-api"
        tag        = "latest"
      }
    }
    inference      = {
      image        = {
        pull       = "Always"
        repository = "public.ecr.aws/c9r4x6y5/eyelevel/layout-inference"
        tag        = "latest"
      }
      image_op     = {
        pull       = "Always"
        repository = "public.ecr.aws/c9r4x6y5/eyelevel/layout-inference-op"
        tag        = "latest"
      }
    }
    models         = {
      device       = "cuda"
      figure       = {
        name       = "fg_faster_rcnn_R_50_FPN_3x - fine tuned"
        pth        = "https://upload.groundx.ai/layout/model/current/fg_faster_rcnn_R_50_FPN_3x.071924.pth"
        yml        = "https://upload.groundx.ai/layout/model/current/fg_faster_rcnn_R_50_FPN_3x_config.071924.yml"
      }
      table        = {
        name       = "tb_faster_rcnn_R_101_FPN_3x - fine tuned 2-21-2024"
        pth        = "https://upload.groundx.ai/layout/model/current/tb_faster_rcnn_R_101_FPN_3x.pth"
        yml        = "https://upload.groundx.ai/layout/model/current/tb_faster_rcnn_R_101_FPN_3x_config.yml"
      }
    }
    nodes          = {
      api          = "cpu"
      inference    = "gpu"
      ocr          = "cpu"
      process      = "cpu"
    }
    process        = {
      image        = {
        pull       = "Always"
        repository = "public.ecr.aws/c9r4x6y5/eyelevel/layout-process"
        tag        = "latest"
      }
    }
    service        = "layout"
    version        = "0.0.1"
  }
}

variable "layout_resources" {
  description   = "Layout compute resource information"
  type          = object({
    inference   = object({
      gpuMemory = string
      replicas  = number
      workers   = number
    })
  })
  default     = {
    inference = {
      gpuMemory = "16gb"
      replicas  = 1
      workers   = 14
    }
  }
}


# LAYOUT WEBHOOK

variable "layout_webhook_internal" {
  description    = "Layout webhook internal settings"
  type           = object({
    image        = object({
      pull       = string
      repository = string
      tag        = string
    })
    node         = string
    service      = string
    version      = string
  })
  default        = {
    image        = {
      pull       = "Always"
      repository = "public.ecr.aws/c9r4x6y5/eyelevel/layout-webhook"
      tag        = "latest"
    }
    node         = "cpu"
    service      = "layout-webhook"
    version      = "0.0.1"
  }
}


# PRE-PROCESS

variable "pre_process_internal" {
  description    = "Pre-Process internal settings"
  type           = object({
    image        = object({
      pull       = string
      repository = string
      tag        = string
    })
    node         = string
    service      = string
    version      = string
  })
  default        = {
    image        = {
      pull       = "Always"
      repository = "public.ecr.aws/c9r4x6y5/eyelevel/pre-process"
      tag        = "latest"
    }
    node         = "cpu"
    service      = "pre-process"
    version      = "0.0.1"
  }
}


# PROCESS

variable "process_internal" {
  description    = "Process internal settings"
  type           = object({
    image        = object({
      pull       = string
      repository = string
      tag        = string
    })
    node         = string
    service      = string
    version      = string
  })
  default        = {
    image        = {
      pull       = "Always"
      repository = "public.ecr.aws/c9r4x6y5/eyelevel/process"
      tag        = "latest"
    }
    node         = "cpu"
    service      = "process"
    version      = "0.0.1"
  }
}


# QUEUE

variable "queue_internal" {
  description    = "Queue internal settings"
  type           = object({
    image        = object({
      pull       = string
      repository = string
      tag        = string
    })
    node          = string
    service      = string
    version      = string
  })
  default        = {
    image        = {
      pull       = "Always"
      repository = "public.ecr.aws/c9r4x6y5/eyelevel/queue"
      tag        = "latest"
    }
    node          = "cpu"
    service      = "queue"
    version      = "0.0.1"
  }
}


# RANKER

variable "ranker_internal" {
  description    = "Ranker internal settings"
  type           = object({
    api            = object({
      image        = object({
        pull       = string
        repository = string
        tag        = string
      })
    })
    inference      = object({
      device       = string
      image        = object({
        pull       = string
        repository = string
        tag        = string
      })
      image_op     = object({
        pull       = string
        repository = string
        tag        = string
      })
      max_batch    = number
      max_prompt   = number
      model        = string
    })
    nodes       = object({
      api       = string
      inference = string
    })
    service        = string
    version        = string
  })
  default        = {
    api            = {
      image        = {
        pull       = "Always"
        repository = "public.ecr.aws/c9r4x6y5/eyelevel/python-api"
        tag        = "latest"
      }
    }
    inference      = {
      device       = "cuda"
      image        = {
        pull       = "Always"
        repository = "public.ecr.aws/c9r4x6y5/eyelevel/ranker-inference"
        tag        = "latest"
      }
      image_op     = {
        pull       = "Always"
        repository = "public.ecr.aws/c9r4x6y5/eyelevel/ranker-inference-op"
        tag        = "latest"
      }
      max_batch    = 10
      max_prompt   = 2048
      model        = "facebook/opt-350m"
    }
    nodes       = {
      api       = "cpu"
      inference = "gpu"
    }
    service        = "ranker"
    version        = "0.0.1"
  }
}

variable "ranker_resources" {
  description = "Ranker compute resource information"
  type          = object({
    inference   = object({
      gpuMemory = string
      replicas  = number
      workers   = number
    })
  })
  default     = {
    inference = {
      gpuMemory = "16gb"
      replicas  = 1
      workers   = 14
    }
  }
}


# SEARCH

variable "search" {
  description     = "Search service information"
  type            = object({
    index         = string
    password      = string
    root_password = string
    user          = string
  })
  default         = {
    index         = "prod-1"
    password      = "R0otb_*t!kazs"
    root_password = "R0otb_*t!kazs"
    user          = "eyelevel"
  }
}

variable "search_existing" {
  description = "Search settings, if using an existing OpenSearch instance outside of Kubernetes"
  type            = object({
    # no protocol, no port
    base_domain   = string

    # includes protocol and port
    base_url      = string

    port          = number
  })
  default         = {
    base_domain   = null
    base_url      = null
    port          = null
  }
}

variable "search_internal" {
  description    = "Search internal settings"
  type           = object({
    chart        = object({
      name       = string
      url        = string
      version    = string
    })
    image        = object({
      name       = string
      repository = string
      tag        = string
    })
    node         = string
    port         = number
    service      = string
    version      = string
  })
  default        = {
    chart        = {
      name       = "opensearch"
      url        = "https://opensearch-project.github.io/helm-charts"
      version    = "2.23.1"
    }
    image        = {
      name       = "eyelevel/opensearch"
      repository = "public.ecr.aws/c9r4x6y5"
      tag        = "latest"
    }
    node         = "cpu"
    port         = 9200
    service      = "opensearch"
    version      = "2.16.0"
  }
}

variable "search_resources" {
  description     = "Search compute resource information"
  type            = object({
    pv_size       = string
    replicas      = number
    resources     = object({
      requests    = object({
        cpu       = string
        memory    = string
      })
    })
  })
  default         = {
    pv_size       = "20Gi"
    replicas      = 3
    resources     = {
      requests    = {
        cpu       = "1"
        memory    = "512Mi"
      }
    }
  }
}


# STREAM

variable "stream_base_url" {
  description = "Kafka base URL, if using an existing Kafka instance outside of Kubernetes"
  nullable    = true
  type        = string
  default     = null
}

variable "stream_existing" {
  description = "Stream settings, if using an existing Kafka instance outside of Kubernetes"
  type            = object({
    # no protocol, no port
    base_domain   = string

    # includes protocol and port
    base_url      = string

    port          = number
  })
  default         = {
    base_domain   = null
    base_url      = null
    port          = null
  }
}

variable "stream_internal" {
  description = "Stream internal settings"
  type        = object({
    chart     = object({
      url     = string
      version = string
    })
    node      = string
    port      = number
    service   = string
    version   = string
  })
  default     = {
    chart     = {
      url     = "oci://quay.io/strimzi-helm/strimzi-kafka-operator"
      version = "0.35.0"
    }
    node      = "cpu"
    port      = 9092
    service   = "kafka"
    version   = "3.4.0"
  }
}

variable "stream_resources" {
  description       = "Stream compute resource information"
  type              = object({
    operator        = object({
      replicas      = number
    })
    partitions      = number
    resources       = object({
      limits        = object({
        cpu         = string
        memory      = string
      })
      requests      = object({
        cpu         = string
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
    operator        = {
      replicas      = 3
    }
    partitions      = 3
    resources       = {
      limits        = {
        cpu         = "4"
        memory      = "8Gi"
      }
      requests      = {
        cpu         = "2"
        memory      = "4Gi"
      }
    }
    retention_bytes = 1073741824
    segment_bytes   = 1073741824
    service         = {
      replicas      = 3
      storage       = "20Gi"
    }
    zookeeper       = {
      replicas      = 3
      storage       = "10Gi"
    }
  }
}


# SUMMARY

variable "summary_existing" {
  description = "Summary settings, if using OpenAI vs private hosted model"
  nullable    = true
  type        = object({
    api_key   = string
    base_url  = string
  })
  default     = {
    api_key   = null
    base_url  = null
  }
}

variable "summary_internal" {
  description    = "Summary internal settings"
  type           = object({
    api            = object({
      image        = object({
        pull       = string
        repository = string
        tag        = string
      })
    })
    inference      = object({
      device       = string
      image        = object({
        pull       = string
        repository = string
        tag        = string
      })
      image_op     = object({
        pull       = string
        repository = string
        tag        = string
      })
      max_batch    = number
      max_prompt   = number
      model        = string
    })
    nodes          = object({
      api          = string
      inference    = string
    })
    service        = string
    version        = string
  })
  default        = {
    api            = {
      image        = {
        pull       = "Always"
        repository = "public.ecr.aws/c9r4x6y5/eyelevel/python-api"
        tag        = "latest"
      }
    }
    inference      = {
      device       = "cuda"
      image        = {
        pull       = "Always"
        repository = "public.ecr.aws/c9r4x6y5/eyelevel/summary-inference"
        tag        = "latest"
      }
      image_op     = {
        pull       = "Always"
        repository = "public.ecr.aws/c9r4x6y5/eyelevel/summary-inference-op"
        tag        = "latest"
      }
      max_batch    = 10
      max_prompt   = 2048
      model        = "openbmb/MiniCPM-V-2_6"
    }
    nodes          = {
      api          = "cpu"
      inference    = "gpu"
    }
    service        = "summary"
    version        = "0.0.1"
  }
}

variable "summary_resources" {
  description   = "Summary compute resource information"
  type          = object({
    inference   = object({
      gpuMemory = string
      replicas  = number
      workers   = number
    })
  })
  default       = {
    inference   = {
      gpuMemory = "24gb"
      replicas  = 1
      workers   = 1
    }
  }
}


# SUMMARY CLIENT

variable "summary_client_internal" {
  description    = "Summary client internal settings"
  type           = object({
    image        = object({
      pull       = string
      repository = string
      tag        = string
    })
    node         = string
    service      = string
    version      = string
  })
  default        = {
    image        = {
      pull       = "Always"
      repository = "public.ecr.aws/c9r4x6y5/eyelevel/summary-client"
      tag        = "latest"
    }
    node         = "cpu"
    service      = "summary-client"
    version      = "0.0.1"
  }
}


# UPLOAD

variable "upload_internal" {
  description    = "Upload client internal settings"
  type           = object({
    image        = object({
      pull       = string
      repository = string
      tag        = string
    })
    node         = string
    service      = string
    version      = string
  })
  default        = {
    image        = {
      pull       = "Always"
      repository = "public.ecr.aws/c9r4x6y5/eyelevel/upload"
      tag        = "latest"
    }
    node         = "cpu"
    service      = "upload"
    version      = "0.0.1"
  }
}