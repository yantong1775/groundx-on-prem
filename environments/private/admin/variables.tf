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
    role             = "developer"
    type             = "openshift"
  }
}

variable "create" {
  description      = "Controls which services are released via Helm"
  type             = object({
    all            = bool

    # document ingestion related services
    ingest         = bool

    # search related services
    search         = bool

    # individual services
    groundx        = bool
    kafka          = bool
    layout         = bool
    layout_webhook = bool
    minio          = bool
    mysql          = bool
    opensearch     = bool
    pre_process    = bool
    process        = bool
    queue          = bool
    ranker         = bool
    redis          = bool
    summary        = bool
    summary_client = bool
    upload         = bool
  })
  default          = {
    all            = true
    ingest         = true
    search         = true

    groundx        = true
    kafka          = true
    layout         = true
    layout_webhook = true
    minio          = true
    mysql          = true
    opensearch     = true
    pre_process    = true
    process        = true
    queue          = true
    ranker         = true
    redis          = true
    summary        = true
    summary_client = true
    upload         = true
  }
}


# CACHE

variable "cache" {
  description  = "Cache service information"
  type         = object({
    node       = string
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
    node       = "crc"
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
    operator_version = "v7.4.6-2"
    port             = 6379
    service          = "redis"
    version          = "6.1"
  }
}


# DASHBOARD

variable "dashboard" {
  description = "Web dashboard information"
  type        = object({
    node      = string
  })
  default     = {
    node      = "crc"
  }
}

variable "dashboard_internal" {
  description = "Web dashboard internal settings"
  type        = object({
    service   = string
  })
  default     = {
    service   = "dashboard"
  }
}


# DATABASE

variable "db" {
  description = "Database service information"
  type        = object({
    db_password      = string
    db_root_password = string
    proxy            = object({
      replicas       = number
      resources      = object({
        limits       = object({
          cpu        = string
          memory     = string
        })
        requests     = object({
          cpu        = string
          memory     = string
        })
      })
    })
    node             = string
    pv_size          = string
    replicas         = number
    resources        = object({
      limits         = object({
        cpu          = string
        memory       = string
      })
      requests       = object({
        cpu          = string
        memory       = string
      })
    })
  })
  default            = {
    db_password      = "password"
    db_root_password = "password"
    proxy            = {
      replicas       = 3
      resources      = {
        limits       = {
          cpu        = "600m"
          memory     = "1Gi"
        }
        requests     = {
          cpu        = "600m"
          memory     = "1Gi"
        }
      }
    }
    node             = "crc"
    pv_size          = "20Gi"
    replicas         = 3
    resources        = {
      limits         = {
        cpu          = "600m"
        memory       = "1Gi"
      }
      requests       = {
        cpu          = "600m"
        memory       = "1Gi"
      }
    }
  }
}

variable "db_internal" {
  description             = "Database internal settings"
  type                    = object({
    backup                = bool
    chart                 = object({
      db                  = string
      operator            = string
    })
    db_name               = string
    db_username           = string
    disable_unsafe_checks = bool
    ip_type               = string
    logcollector_enable   = bool
    pmm_enable            = bool
    service               = string
    version               = string
  })
  default                 = {
    backup                = true
    chart                 = {
      db                  = "percona/pxc-db"
      operator            = "percona/pxc-operator"
    }
    db_name               = "eyelevel"
    db_username           = "eyelevel"
    disable_unsafe_checks = false
    ip_type               = "ClusterIP"
    logcollector_enable   = true
    pmm_enable            = false
    service               = "eyelevel"
    version               = "8.0"
  }
}


# FILE

variable "file" {
  description           = "Database service information"
  type                  = object({
    access_key          = string
    access_secret       = string
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
    access_key          = "minio"
    access_secret       = "minio123"
    node                = "crc"
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

variable "file_internal" {
  description        = "Database internal settings"
  type               = object({
    chart_base       = string
    chart_repository = string
    operator         = object({
      chart          = string
      chart_version  = string
    })
    pv_access        = string
    service          = string
    tenant           = object({
      chart          = string
      chart_version  = string
    })
    upload_bucket    = string
    version          = string
  })
  default            = {
    chart_base       = "minio-operator"
    chart_repository = "https://operator.min.io"
    operator         = {
      chart          = "minio-operator/operator"
      chart_version  = "6.0.3"
    }
    pv_access        = "ReadWriteMany"
    service          = "minio"
    tenant           = {
      chart          = "minio-operator/tenant"
      chart_version  = "6.0.3"
    }
    upload_bucket    = "eyelevel"
    version          = "6.0.3"
  }
}


# GROUNDX

variable "groundx" {
  description     = "GroundX service information"
  type            = object({
    load_balancer = object({
      port        = number
    })
    node          = string
  })
  default         = {
    load_balancer = {
      port        = 80
    }
    node          = "crc"
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
    service      = string
    version      = string
  })
  default        = {
    image        = {
      pull       = "Always"
      repository = "public.ecr.aws/c9r4x6y5/eyelevel/groundx"
      tag        = "latest"
    }
    service      = "groundx"
    version      = "0.0.1"
  }
}


# LAYOUT

variable "layout" {
  description   = "Layout service information"
  type          = object({
    nodes       = object({
      api       = string
      inference = string
      ocr       = string
      process   = string
    })
  })
  default       = {
    nodes       = {
      api       = "crc"
      inference = "crc"
      ocr       = "crc"
      process   = "crc"
    }
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

variable "layout_ocr" {
  type            = object({
    credentials   = string
    project       = string
    type          = string
  })
  default         = {
    credentials   = "gcv_credentials.json"
    project       = ""
    type          = "google"
  }
  validation {
    condition     = var.layout_ocr.type != "google" || var.layout_ocr.project != ""
    error_message = "Project must be set if using Google OCR"
  }
}


# LAYOUT WEBHOOK

variable "layout_webhook" {
  description     = "Layout webhook service information"
  type            = object({
    node          = string
  })
  default         = {
    node          = "crc"
  }
}

variable "layout_webhook_internal" {
  description    = "Layout webhook internal settings"
  type           = object({
    image        = object({
      pull       = string
      repository = string
      tag        = string
    })
    service      = string
    version      = string
  })
  default        = {
    image        = {
      pull       = "Always"
      repository = "public.ecr.aws/c9r4x6y5/eyelevel/layout-webhook"
      tag        = "latest"
    }
    service      = "groundx"
    version      = "0.0.1"
  }
}


# PRE-PROCESS

variable "pre_process" {
  description     = "Pre-Process service information"
  type            = object({
    node          = string
  })
  default         = {
    node          = "crc"
  }
}

variable "pre_process_internal" {
  description    = "Pre-Process internal settings"
  type           = object({
    image        = object({
      pull       = string
      repository = string
      tag        = string
    })
    service      = string
    version      = string
  })
  default        = {
    image        = {
      pull       = "Always"
      repository = "public.ecr.aws/c9r4x6y5/eyelevel/pre-process"
      tag        = "latest"
    }
    service      = "pre-process"
    version      = "0.0.1"
  }
}


# PROCESS

variable "process" {
  description     = "Process service information"
  type            = object({
    node          = string
  })
  default         = {
    node          = "crc"
  }
}

variable "process_internal" {
  description    = "Process internal settings"
  type           = object({
    image        = object({
      pull       = string
      repository = string
      tag        = string
    })
    service      = string
    version      = string
  })
  default        = {
    image        = {
      pull       = "Always"
      repository = "public.ecr.aws/c9r4x6y5/eyelevel/process"
      tag        = "latest"
    }
    service      = "process"
    version      = "0.0.1"
  }
}


# QUEUE

variable "queue" {
  description     = "Queue service information"
  type            = object({
    node          = string
  })
  default         = {
    node          = "crc"
  }
}

variable "queue_internal" {
  description    = "Queue internal settings"
  type           = object({
    image        = object({
      pull       = string
      repository = string
      tag        = string
    })
    service      = string
    version      = string
  })
  default        = {
    image        = {
      pull       = "Always"
      repository = "public.ecr.aws/c9r4x6y5/eyelevel/queue"
      tag        = "latest"
    }
    service      = "queue"
    version      = "0.0.1"
  }
}


# RANKER

variable "ranker" {
  description   = "Ranker service information"
  type          = object({
    nodes       = object({
      api       = string
      inference = string
    })
  })
  default       = {
    nodes       = {
      api       = "crc"
      inference = "crc"
    }
  }
}

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
    service        = "ranker"
    version        = "0.0.1"
  }
}


# SEARCH

variable "search" {
  description     = "Search service information"
  type            = object({
    node          = string
    password      = string
    pv_size       = string
    replicas      = number
    resources     = object({
      requests    = object({
        cpu       = string
        memory    = string
      })
    })
    root_password = string
  })
  default         = {
    node          = "crc"
    password      = "R0otb_*t!kazs"
    pv_size       = "1Gi"
    replicas      = 3
    resources     = {
      requests    = {
        cpu       = "1"
        memory    = "512Mi"
      }
    }
    root_password = "R0otb_*t!kazs"
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
    index        = string
    service      = string
    user         = string
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
    index        = "prod-1"
    service      = "opensearch"
    user         = "eyelevel"
    version      = "2.16.0"
  }
}


# STREAM

variable "stream" {
  description       = "Stream service information"
  type              = object({
    node            = string
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
    node            = "crc"
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

variable "stream_internal" {
  description = "Stream internal settings"
  type        = object({
    chart     = object({
      url     = string
      version = string
    })
    port      = number
    service   = string
    version   = string
  })
  default     = {
    chart     = {
      url     = "oci://quay.io/strimzi-helm/strimzi-kafka-operator"
      version = "0.35.0"
    }
    port      = 9092
    service   = "kafka"
    version   = "2.16.0"
  }
}


# SUMMARY

variable "summary" {
  description   = "Summary service information"
  type          = object({
    nodes       = object({
      api       = string
      inference = string
    })
  })
  default       = {
    nodes       = {
      api       = "crc"
      inference = "crc"
    }
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
    service        = "summary"
    version        = "0.0.1"
  }
}


# SUMMARY CLIENT

variable "summary_client" {
  description     = "Summary client service information"
  type            = object({
    node          = string
  })
  default         = {
    node          = "crc"
  }
}

variable "summary_client_internal" {
  description    = "Summary client internal settings"
  type           = object({
    image        = object({
      pull       = string
      repository = string
      tag        = string
    })
    service      = string
    version      = string
  })
  default        = {
    image        = {
      pull       = "Always"
      repository = "public.ecr.aws/c9r4x6y5/eyelevel/summary-client"
      tag        = "latest"
    }
    service      = "summary-client"
    version      = "0.0.1"
  }
}


# UPLOAD

variable "upload" {
  description     = "Upload client service information"
  type            = object({
    node          = string
  })
  default         = {
    node          = "crc"
  }
}

variable "upload_internal" {
  description    = "Upload client internal settings"
  type           = object({
    image        = object({
      pull       = string
      repository = string
      tag        = string
    })
    service      = string
    version      = string
  })
  default        = {
    image        = {
      pull       = "Always"
      repository = "public.ecr.aws/c9r4x6y5/eyelevel/upload"
      tag        = "latest"
    }
    service      = "upload"
    version      = "0.0.1"
  }
}