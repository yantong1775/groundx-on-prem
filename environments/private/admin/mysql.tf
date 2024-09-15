resource "null_resource" "percona_helm_repo" {
  count = local.create_mysql ? 1 : 0

  provisioner "local-exec" {
    command = "helm repo add percona https://percona.github.io/percona-helm-charts && helm repo update"
  }
}

resource "helm_release" "percona_operator" {
  count      = local.create_mysql ? 1 : 0

  depends_on = [null_resource.percona_helm_repo, kubernetes_namespace.eyelevel]

  name       = "${var.db_internal.service}-operator"
  namespace  = var.app.namespace

  chart      = var.db_internal.chart.operator
}

resource "helm_release" "percona_cluster" {
  count      = local.create_mysql ? 1 : 0

  depends_on = [helm_release.percona_operator]

  name       = "${var.db_internal.service}-cluster"
  namespace  = var.app.namespace

  chart      = var.db_internal.chart.db

  values = [
    yamlencode({
      backup = {
        enabled = var.db_internal.backup
      }
      haproxy = {
        enabled = true
        resources = var.db.proxy.resources
        size    = var.db.proxy.replicas
      }
      logcollector = {
        enabled = var.db_internal.logcollector_enable
      }
      pmm = {
        enabled = var.db_internal.pmm_enable
      }
      proxysql = {
        enabled = false
      }
      pxc = {
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

  timeout = 600
}