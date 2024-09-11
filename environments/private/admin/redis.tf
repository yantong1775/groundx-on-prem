resource "kubernetes_persistent_volume" "redis_pv" {
  count = local.create_redis ? (var.pv_class == "empty" ? 0 : 1) : 0

  metadata {
    name = "${var.cache_service}-pv"
    labels = {
      type = var.pv_class
      app = var.cache_service
    }
  }

  spec {
    capacity = {
      storage = var.cache_pv_size
    }

    access_modes = [var.cache_pv_access]

    persistent_volume_source {
      local {
        path = var.cache_pv_path
      }
    }

    persistent_volume_reclaim_policy = "Retain"
    storage_class_name               = var.pv_class

    node_affinity {
      required {
        node_selector_term {
          match_expressions {
            key      = "kubernetes.io/hostname"
            operator = "In"
            values   = [var.cache_node]
          }
        }
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "redis_pvc" {
  count = local.create_redis ? (var.pv_class == "empty" ? 0 : 1) : 0

  depends_on = [kubernetes_namespace.eyelevel]

  metadata {
    name       = "${var.cache_service}-pvc"
    namespace  = var.namespace
    labels = {
      type = var.pv_class
      app = var.cache_service
    }
  }

  spec {
    selector {
      match_labels = {
        app = var.cache_service
      }
    }

    storage_class_name = var.pv_class

    access_modes = [var.cache_pv_access]

    resources {
      requests = {
        storage = var.cache_pv_size
      }
    }
  }
}

resource "helm_release" "redis" {
  count = local.create_redis ? 1 : 0

  depends_on = [kubernetes_persistent_volume_claim.redis_pvc]

  name       = var.cache_service
  namespace  = var.namespace

  chart      = "${path.module}/../../../modules/redis/helm_chart"

  values = [
    yamlencode({
      image = {
        pull       = var.cache_image_pull
        repository = var.cache_image_url
        tag        = var.cache_image_tag
        version    = var.cache_version
      },
      persistence = {
        claim        = "${var.cache_service}-pvc"
        mountPath    = var.cache_mount_path
        storageClass = var.pv_class
        volume       = "${var.cache_service}-pv"
      },
      securityContext = {
        runAsUser  = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.UID, 1001) : 1001
        runAsGroup = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.GID, 1001) : 1001
        fsGroup    = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.GID, 1001) : 1001
      },
      service = {
        name         = var.cache_service
        namespace    = var.namespace
        port         = var.cache_port
        replicaCount = var.cache_replicas
        type         = var.cache_ip_type
      }
    })
  ]

  timeout = 600
}