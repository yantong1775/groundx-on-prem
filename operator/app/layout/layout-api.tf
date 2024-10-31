resource "helm_release" "layout_api_service" {
  name       = "${var.layout_internal.service}-api"
  namespace  = var.app_internal.namespace

  chart      = "${local.module_path}/layout/api/helm_chart"

  values = [
    yamlencode({
      dependencies = {
        cache = "${local.cache_settings.addr} ${local.cache_settings.port}"
      }
      image = var.layout_internal.api.image
      nodeSelector    = {
        node          = var.cluster_internal.nodes.cpu_only
      }
      securityContext = {
        runAsUser  = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.UID, 1001) : 1001
      }
      service = {
        name      = "${var.layout_internal.service}-api"
        namespace = var.app_internal.namespace
        version   = var.layout_internal.version
      }
    })
  ]
}