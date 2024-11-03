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
        node = var.cluster_internal.nodes.cpu_memory
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
          node = var.cluster_internal.nodes.cpu_memory
        }
      }
      haproxy = {
        enabled = true
        nodeSelector = {
          node = var.cluster_internal.nodes.cpu_memory
        }
        resources = var.db_resources.proxy.resources
        size    = var.db_resources.proxy.replicas
      }
      logcollector = {
        enabled = var.db_internal.logcollector_enable
        nodeSelector = {
          node = var.cluster_internal.nodes.cpu_memory
        }
      }
      nodeSelector = {
        node = var.cluster_internal.nodes.cpu_memory
      }
      pmm = {
        enabled = var.db_internal.pmm_enable
        nodeSelector = {
          node = var.cluster_internal.nodes.cpu_memory
        }
      }
      proxysql = {
        enabled = false
        nodeSelector = {
          node = var.cluster_internal.nodes.cpu_memory
        }
      }
      pxc = {
        nodeSelector = {
          node = var.cluster_internal.nodes.cpu_memory
        }
        persistence = {
          size = var.db_resources.pv_size
        }
        resources = var.db_resources.resources
        size = var.db_resources.replicas
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