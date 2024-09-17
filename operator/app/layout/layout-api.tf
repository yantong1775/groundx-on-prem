resource "helm_release" "layout_api_service" {
  name       = "${var.layout_internal.service}-api"
  namespace  = var.app.namespace

  chart      = "${local.module_path}/layout/api/helm_chart"

  values = [
    yamlencode({
      dependencies = {
        cache = "${var.cache_internal.service}.${var.app.namespace}.svc.cluster.local"
      }
      image = var.layout_internal.api.image
      nodeSelector    = {
        node          = var.layout.nodes.api
      }
      securityContext = {
        runAsUser  = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.UID, 1001) : 1001
      }
      service = {
        name      = "${var.layout_internal.service}-api"
        namespace = var.app.namespace
        version   = var.layout_internal.version
      }
    })
  ]
}