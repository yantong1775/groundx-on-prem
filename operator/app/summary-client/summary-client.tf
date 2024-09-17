resource "helm_release" "summary_client_service" {
  name       = "${var.summary_client_internal.service}-cluster"
  namespace  = var.app.namespace
  chart      = "${local.module_path}/summary-client/helm_chart"

  values = [
    yamlencode({
      dependencies = {
        groundx  = "${var.groundx_internal.service}.${var.app.namespace}.svc.cluster.local"
      }
      image = var.summary_client_internal.image
      nodeSelector = {
        node = var.summary_client.node
      }
      securityContext = {
        runAsUser  = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.UID, 1001) : 1001
        runAsGroup = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.GID, 1001) : 1001
        fsGroup    = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.GID, 1001) : 1001
      }
      service = {
        name      = var.summary_client_internal.service
        namespace = var.app.namespace
        version   = var.summary_client_internal.version
      }
    })
  ]
}