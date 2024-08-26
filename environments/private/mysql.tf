resource "kubernetes_persistent_volume" "mysql_pv" {
  metadata {
    name = "${var.db_service}-pv"
    labels = {
      type = var.pv_class
      app = var.db_service
    }
  }

  spec {
    capacity = {
      storage = var.db_pv_size
    }

    access_modes = [var.db_pv_access]

    persistent_volume_source {
      local {
        path = var.db_pv_path
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
            values   = [var.db_node]
          }
        }
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "mysql_pvc" {
  metadata {
    name = "${var.db_service}-pvc"
    namespace  = var.namespace
    labels = {
      type = var.pv_class
      app = var.db_service
    }
  }

  spec {
    selector {
      match_labels = {
        app = var.db_service
      }
    }

    storage_class_name = var.pv_class

    access_modes = [var.db_pv_access]

    resources {
      requests = {
        storage = var.db_pv_size
      }
    }
  }
}

resource "kubernetes_secret" "mysql_secret" {
  metadata {
    name      = "${var.db_service}-secret"
    namespace = var.namespace
  }

  data = {
    MYSQL_DATABASE      = var.db_name
    MYSQL_USER          = var.db_username
    MYSQL_PASSWORD      = var.db_password
    MYSQL_ROOT_PASSWORD = var.db_root_password
  }
}

resource "helm_release" "mysql" {
  name       = var.db_service
  chart      = "${path.module}/../../modules/mysql/helm_chart"
  namespace  = var.namespace

  values = [
    yamlencode({
      image = {
        pull       = var.db_image_pull
        repository = var.db_image_url
        tag        = var.db_image_tag
        version    = var.db_version
      },
      persistence = {
        claim        = "${var.db_service}-pvc"
        mountPath    = var.db_mount_path
        storageClass = var.pv_class
        volume       = "${var.db_service}-pv"
      },
      securityContext = {
        runAsUser  = data.external.get_uid_gid.result.UID
        runAsGroup = data.external.get_uid_gid.result.GID
        fsGroup    = data.external.get_uid_gid.result.GID
      },
      service = {
        name         = var.db_service
        namespace    = var.namespace
        port         = var.db_port
        replicaCount = var.db_replicas
        type         = var.db_ip_type
      }
    })
  ]

  timeout = 60
}