resource "helm_release" "summary_api_service" {
  name       = "${var.summary_internal.service}-api-cluster"
  namespace  = var.app.namespace

  chart      = "${local.module_path}/summary/api/helm_chart"

  values = [
    yamlencode({
      dependencies = {
        cache = "${var.cache_internal.service}.${var.app.namespace}.svc.cluster.local"
      }
      image = var.summary_internal.api.image
      nodeSelector = {
        node = var.summary.nodes.api
      }
      securityContext = {
        runAsUser  = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.UID, 1001) : 1001
      }
      service = {
        name      = "${var.summary_internal.service}-api"
        namespace = var.app.namespace
        version   = var.summary_internal.version
      }
    })
  ]
}