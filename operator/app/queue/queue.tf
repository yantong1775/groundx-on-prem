resource "helm_release" "queue_service" {
  name       = "${var.queue_internal.service}-cluster"
  namespace  = var.app.namespace
  chart      = "${local.module_path}/queue/helm_chart"

  values = [
    yamlencode({
      dependencies = {
        groundx  = "${var.groundx_internal.service}.${var.app.namespace}.svc.cluster.local"
      }
      image = var.queue_internal.image
      securityContext = {
        runAsUser  = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.UID, 1001) : 1001
        runAsGroup = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.GID, 1001) : 1001
        fsGroup    = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.GID, 1001) : 1001
      }
      service = {
        name      = var.queue_internal.service
        namespace = var.app.namespace
        version   = var.queue_internal.version
      }
    })
  ]
}