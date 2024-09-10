resource "null_resource" "percona_helm_repo" {
  count = local.create_mysql ? 1 : 0

  provisioner "local-exec" {
    command = "helm repo add percona https://percona.github.io/percona-helm-charts && helm repo update"
  }
}

resource "helm_release" "percona_operator" {
  count      = local.create_mysql ? 1 : 0

  depends_on = [null_resource.percona_helm_repo, kubernetes_namespace.eyelevel]

  name       = "${var.db_service}-operator"
  namespace  = var.namespace

  chart      = "percona/pxc-operator"
}

resource "helm_release" "percona_cluster" {
  count      = local.create_mysql ? 1 : 0

  depends_on = [helm_release.percona_operator]

  name       = "${var.db_service}-cluster"
  namespace  = var.namespace

  chart      = "percona/pxc-db"

  values = [
    yamlencode({
      backup = {
        enabled = var.db_backup_enable
      }
      haproxy = {
        enabled = true
        resources = {
          limits = {
            cpu    = var.db_ha_proxy_cpu_limits
            memory = var.db_ha_proxy_memory_limits
          }
          requests = {
            cpu    = var.db_ha_proxy_cpu_requests
            memory = var.db_ha_proxy_memory_requests
          }
        }
        size    = var.db_ha_proxy_replicas
      }
      logcollector = {
        enabled = var.db_logcollector_enable
      }
      pmm = {
        enabled = var.db_pmm_enable
      }
      proxysql = {
        enabled = false
      }
      pxc = {
        persistence = {
          size = var.db_pv_size
        }
        resources = {
          limits = {
            cpu    = var.db_pxc_cpu_limits
            memory = var.db_pxc_memory_limits
          }
          requests = {
            cpu    = var.db_pxc_cpu_requests
            memory = var.db_pxc_memory_requests
          }
        }
        size = var.db_replicas
      }
      secrets = {
        passwords = {
          root         = var.db_root_password
          xtrabackup   = var.db_root_password
          monitor      = var.db_root_password
          clustercheck = var.db_root_password
          proxyadmin   = var.db_root_password
          operator     = var.db_root_password
          replication  = var.db_root_password
        }
        tls = {
          cluster  = "${var.namespace}-cert"
          internal = "${var.namespace}-cert"
        }
      }
      unsafeFlags = {
        pxcSize   = var.db_disable_check_unsafe
        proxySize = var.db_disable_check_unsafe
      }
    })
  ]

  timeout = 600
}