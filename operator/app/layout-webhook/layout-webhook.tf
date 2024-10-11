resource "helm_release" "layout_webhook_service" {
  name       = "${var.layout_webhook_internal.service}"
  namespace  = var.app_internal.namespace
  chart      = "${local.module_path}/layout-webhook/helm_chart"

  values = [
    yamlencode({
      dependencies = {
        groundx  = "${var.groundx_internal.service}.${var.app_internal.namespace}.svc.cluster.local"
      }
      image = var.layout_webhook_internal.image
      nodeSelector = {
        node = var.layout_webhook_internal.node
      }
      securityContext = {
        runAsUser  = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.UID, 1001) : 1001
        runAsGroup = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.GID, 1001) : 1001
        fsGroup    = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.GID, 1001) : 1001
      }
      service = {
        name      = var.layout_webhook_internal.service
        namespace = var.app_internal.namespace
        version   = var.layout_webhook_internal.version
      }
    })
  ]
}