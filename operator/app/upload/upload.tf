resource "helm_release" "upload_service" {
  name       = "${var.upload_internal.service}-cluster"
  namespace  = var.app_internal.namespace
  chart      = "${local.module_path}/upload/helm_chart"

  values = [
    yamlencode({
      dependencies = {
        groundx  = "${var.groundx_internal.service}.${var.app_internal.namespace}.svc.cluster.local"
      }
      image = var.upload_internal.image
      nodeSelector = {
        node = var.cluster_internal.nodes.cpu_only
      }
      securityContext = {
        runAsUser  = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.UID, 1001) : 1001
        runAsGroup = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.GID, 1001) : 1001
        fsGroup    = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.GID, 1001) : 1001
      }
      service = {
        name      = var.upload_internal.service
        namespace = var.app_internal.namespace
        version   = var.upload_internal.version
      }
    })
  ]
}