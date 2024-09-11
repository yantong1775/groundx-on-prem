resource "null_resource" "minio_helm_repo" {
  count = local.create_minio ? 1 : 0

  provisioner "local-exec" {
    command = "helm repo add ${var.file_chart_repository_name} ${var.file_chart_repository} && helm repo update"
  }
}

resource "helm_release" "minio_operator" {
  count = local.create_minio ? 1 : 0

  depends_on = [null_resource.minio_helm_repo, kubernetes_namespace.eyelevel]

  name       = "${var.file_service}-operator"
  namespace  = var.namespace

  chart      = var.file_chart_operator
  version    = var.file_chart_operator_version

  values = [
    yamlencode({
      operator = {
        containerSecurityContext = {
          runAsUser  = tonumber(local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.UID, 1000) : 1000)
          runAsGroup = tonumber(local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.GID, 1000) : 1000)
          fsGroup    = tonumber(local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.GID, 1000) : 1000)
        },
        replicaCount    = var.file_replicas_operator,
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
  count = local.create_minio ? 1 : 0

  depends_on = [helm_release.minio_operator]

  name       = "${var.file_service}-tenant"
  namespace  = var.namespace

  chart      = var.file_chart_tenant
  version    = var.file_chart_tenant_version

  values = [
    yamlencode({
      tenant = {
        configSecret = {
          accessKey = var.file_access_key
          secretKey = var.file_access_secret
        }
        name = "${var.file_service}-tenant"
        pools = [{
          containerSecurityContext = {
            runAsUser  = tonumber(local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.UID, 1000) : 1000)
            runAsGroup = tonumber(local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.GID, 1000) : 1000)
            fsGroup    = tonumber(local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.GID, 1000) : 1000)
          }
          name = "${var.file_service}-tenant-pool-0"
          securityContext = {
            runAsUser  = tonumber(local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.UID, 1000) : 1000)
            runAsGroup = tonumber(local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.GID, 1000) : 1000)
            fsGroup    = tonumber(local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.GID, 1000) : 1000)
          }
          servers          = var.file_pool_server
          size             = var.file_pool_size
          volumesPerServer = var.file_pool_server_volumes
        }],
        resources = {
          requests = {
            memory = var.file_memory_requests
            cpu    = var.file_cpu_requests
          }
          limits = {
            memory = var.file_memory_limits
            cpu    = var.file_cpu_limits
          }
        }
      }
    })
  ]

  timeout = 600
}