resource "null_resource" "percona_helm_repo" {
  count = local.create_database ? 1 : 0

  provisioner "local-exec" {
    command = "helm repo add ${var.db_internal.chart.base} ${var.db_internal.chart.repository} && helm repo update"
  }
}

resource "helm_release" "percona_operator" {
  count = local.create_database ? 1 : 0

  depends_on = [null_resource.percona_helm_repo]

  name       = "${var.db_internal.service}-operator"
  namespace  = var.app_internal.namespace

  chart      = var.db_internal.chart.operator

  values = [
    yamlencode({
      nodeSelector = {
        node = var.db_internal.node
      }
    })
  ]
}

resource "helm_release" "percona_cluster" {
  count = local.create_database ? 1 : 0

  depends_on = [helm_release.percona_operator]

  name       = "${var.db_internal.service}-cluster"
  namespace  = var.app_internal.namespace

  chart      = var.db_internal.chart.db

  values = [
    yamlencode({
      backup = {
        enabled = var.db_internal.backup
        nodeSelector = {
          node = var.db_internal.node
        }
      }
      haproxy = {
        enabled = true
        nodeSelector = {
          node = var.db_internal.node
        }
        resources = var.db_resources.proxy.resources
        size    = var.db_resources.proxy.replicas
      }
      logcollector = {
        enabled = var.db_internal.logcollector_enable
        nodeSelector = {
          node = var.db_internal.node
        }
      }
      nodeSelector = {
        node = var.db_internal.node
      }
      pmm = {
        enabled = var.db_internal.pmm_enable
        nodeSelector = {
          node = var.db_internal.node
        }
      }
      proxysql = {
        enabled = false
        nodeSelector = {
          node = var.db_internal.node
        }
      }
      pxc = {
        nodeSelector = {
          node = var.db_internal.node
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