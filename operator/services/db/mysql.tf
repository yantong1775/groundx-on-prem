resource "null_resource" "percona_helm_repo" {
  provisioner "local-exec" {
    command = "helm repo add ${var.db_internal.chart.base} ${var.db_internal.chart.repository} && helm repo update"
  }
}

resource "helm_release" "percona_operator" {
  depends_on = [null_resource.percona_helm_repo]

  name       = "${var.db_internal.service}-operator"
  namespace  = var.app.namespace

  chart      = var.db_internal.chart.operator

  values = [
    yamlencode({
      nodeSelector = {
        node = var.db.node
      }
    })
  ]
}

resource "helm_release" "percona_cluster" {
  depends_on = [helm_release.percona_operator]

  name       = "${var.db_internal.service}-cluster"
  namespace  = var.app.namespace

  chart      = var.db_internal.chart.db

  values = [
    yamlencode({
      backup = {
        enabled = var.db_internal.backup
        nodeSelector = {
          node = var.db.node
        }
      }
      haproxy = {
        enabled = true
        nodeSelector = {
          node = var.db.node
        }
        resources = var.db.proxy.resources
        size    = var.db.proxy.replicas
      }
      logcollector = {
        enabled = var.db_internal.logcollector_enable
        nodeSelector = {
          node = var.db.node
        }
      }
      nodeSelector = {
        node = var.db.node
      }
      pmm = {
        enabled = var.db_internal.pmm_enable
        nodeSelector = {
          node = var.db.node
        }
      }
      proxysql = {
        enabled = false
        nodeSelector = {
          node = var.db.node
        }
      }
      pxc = {
        nodeSelector = {
          node = var.db.node
        }
        persistence = {
          size = var.db.pv_size
        }
        resources = var.db.resources
        size = var.db.replicas
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
          cluster  = "${var.app.namespace}-cert"
          internal = "${var.app.namespace}-cert"
        }
      }
      unsafeFlags = {
        pxcSize   = var.db_internal.disable_unsafe_checks
        proxySize = var.db_internal.disable_unsafe_checks
      }
    })
  ]
}