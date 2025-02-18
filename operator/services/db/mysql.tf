locals {
  proxy = {
    limits = var.db_resources.proxy.resources.limits.cpu < 1 ? "${var.db_resources.proxy.resources.limits.cpu * 1000}m" : var.db_resources.proxy.resources.limits.cpu
    requests = var.db_resources.proxy.resources.requests.cpu < 1 ? "${var.db_resources.proxy.resources.requests.cpu * 1000}m" : var.db_resources.proxy.resources.requests.cpu
  }
  pxc = {
    limits = var.db_resources.resources.limits.cpu < 1 ? "${var.db_resources.resources.limits.cpu * 1000}m" : var.db_resources.resources.limits.cpu
    requests = var.db_resources.resources.requests.cpu < 1 ? "${var.db_resources.resources.requests.cpu * 1000}m" : var.db_resources.resources.requests.cpu
  }
}

resource "helm_release" "percona_operator" {
  count = local.create_database ? 1 : 0

  name       = "${var.db_internal.service}-operator"
  namespace  = var.app_internal.namespace

  chart      = var.db_internal.chart.operator.name
  repository = var.db_internal.chart.repository
  version    = var.db_internal.chart.operator.version

  values = [
    yamlencode({
      nodeSelector = {
        # node = local.node_assignment.db
        "node_pool" = local.node_assignment.db
      }
    })
  ]
}

resource "helm_release" "percona_cluster" {
  count = local.create_database ? 1 : 0

  depends_on = [helm_release.percona_operator]

  name       = "${var.db_internal.service}-cluster"
  namespace  = var.app_internal.namespace

  chart      = var.db_internal.chart.db.name
  repository = var.db_internal.chart.repository
  version    = var.db_internal.chart.db.version

  values = [
    yamlencode({
      backup = {
        enabled = var.db_internal.backup
        nodeSelector = {
          # node = local.node_assignment.db
        "node_pool" = local.node_assignment.db

        }
      }
      haproxy = {
        enabled = true
        nodeSelector = {
          # node = local.node_assignment.db
        "node_pool" = local.node_assignment.db

        }
        resources = {
          limits            = {
            cpu             = local.proxy.limits
            memory          = var.db_resources.proxy.resources.limits.memory
          }
          requests          = {
            cpu             = local.proxy.requests
            memory          = var.db_resources.proxy.resources.requests.memory
          }
        }
        size    = var.db_resources.proxy.replicas
        readinessDelaySec = "15"
        readinessProbes = {
          initialDelaySeconds= 15
          timeoutSeconds= 3
          periodSeconds= 5
          successThreshold= 1
          failureThreshold= 3
        }
      }
      logcollector = {
        enabled = var.db_internal.logcollector_enable
        nodeSelector = {
          # node = local.node_assignment.db
        "node_pool" = local.node_assignment.db

        }
      }
      nodeSelector = {
        # node = local.node_assignment.db
        "node_pool" = local.node_assignment.db

      }
      pmm = {
        enabled = var.db_internal.pmm_enable
        nodeSelector = {
          # node = local.node_assignment.db
        "node_pool" = local.node_assignment.db

        }
      }
      proxysql = {
        enabled = false
        nodeSelector = {
          # node = local.node_assignment.db
        "node_pool" = local.node_assignment.db

        }
      }
      pxc = {
        nodeSelector = {
          # node = local.node_assignment.db
        "node_pool" = local.node_assignment.db

        }
        persistence = {
          size = var.db_resources.pv_size
        }
        resources = {
          limits            = {
            cpu             = local.pxc.limits
            memory          = var.db_resources.resources.limits.memory
          }
          requests          = {
            cpu             = local.pxc.requests
            memory          = var.db_resources.resources.requests.memory
          }
        }
        size = var.db_resources.replicas
        readinessDelaySec = "60"
      }
      secrets = {
        passwords = {
          root         = var.db.db_root_password
          xtrabackup   = var.db.db_root_password
          monitor      = var.db.db_root_password
          clustercheck = var.db.db_root_password
          proxyadmin   = var.db.db_root_password
          operator     = var.db.db_root_password
          replication  = var.db.db_root_password
        }
        tls = {
          cluster  = "${var.app_internal.namespace}-cert"
          internal = "${var.app_internal.namespace}-cert"
        }
      }
      unsafeFlags = {
        pxcSize   = var.db_internal.disable_unsafe_checks
        proxySize = var.db_internal.disable_unsafe_checks
      }
    })
  ]
}