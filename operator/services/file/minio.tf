resource "null_resource" "minio_helm_repo" {
  count = local.create_file ? 1 : 0

  provisioner "local-exec" {
    command = "helm repo add ${var.file_internal.chart_base} ${var.file_internal.chart_repository} && helm repo update"
  }
}

resource "helm_release" "minio_operator" {
  count = local.create_file ? 1 : 0

  depends_on = [null_resource.minio_helm_repo]

  name       = "${var.file_internal.service}-operator"
  namespace  = var.app_internal.namespace

  chart      = var.file_internal.operator.chart
  version    = var.file_internal.operator.chart_version

  values = [
    yamlencode({
      operator = {
        containerSecurityContext = {
          runAsUser  = tonumber(local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.UID, 1000) : 1000)
          runAsGroup = tonumber(local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.GID, 1000) : 1000)
          fsGroup    = tonumber(local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.GID, 1000) : 1000)
        }
        nodeSelector = {
          node = var.cluster_internal.nodes.cpu_memory
        }
        replicaCount    = var.file_resources.operator.replicas
        securityContext = {
          runAsUser  = tonumber(local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.UID, 1000) : 1000)
          runAsGroup = tonumber(local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.GID, 1000) : 1000)
          fsGroup    = tonumber(local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.GID, 1000) : 1000)
        }
      }
    })
  ]
}

resource "helm_release" "minio_tenant" {
  count = local.create_file ? 1 : 0

  depends_on = [helm_release.minio_operator]

  name       = "${var.file_internal.service}-tenant"
  namespace  = var.app_internal.namespace

  chart      = var.file_internal.tenant.chart
  version    = var.file_internal.tenant.chart_version

  values = [
    yamlencode({
      tenant = {
        certificate = {
          requestAutoCert = false
        }
        configSecret = {
          accessKey = var.file.username
          secretKey = var.file.password
        }
        name = "${var.file_internal.service}-tenant"
        nodeSelector = {
          node = var.cluster_internal.nodes.cpu_memory
        }
        pools = [{
          containerSecurityContext = {
            runAsUser  = tonumber(local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.UID, 1000) : 1000)
            runAsGroup = tonumber(local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.GID, 1000) : 1000)
            fsGroup    = tonumber(local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.GID, 1000) : 1000)
          }
          name = "${var.file_internal.service}-tenant-pool-0"
          nodeSelector = {
            node = var.cluster_internal.nodes.cpu_memory
          }
          securityContext = {
            runAsUser  = tonumber(local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.UID, 1000) : 1000)
            runAsGroup = tonumber(local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.GID, 1000) : 1000)
            fsGroup    = tonumber(local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.GID, 1000) : 1000)
          }
          servers          = var.file_resources.pool_servers
          size             = var.file_resources.pool_size
          volumesPerServer = var.file_resources.pool_server_volumes
        }]
        resources = var.file_resources.resources
      }
    })
  ]
}