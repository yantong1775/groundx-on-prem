resource "helm_release" "ranker_api_service" {
  name       = "${var.ranker_internal.service}-api-cluster"
  namespace  = var.app.namespace

  chart      = "${local.module_path}/ranker/api/helm_chart"

  values = [
    yamlencode({
      dependencies = {
        cache = "${var.cache_internal.service}.${var.app.namespace}.svc.cluster.local"
      }
      image = var.ranker_internal.api.image
      nodeSelector = {
        node = var.ranker.nodes.api
      }
      securityContext = {
        runAsUser  = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.UID, 1001) : 1001
      }
      service = {
        name      = "${var.ranker_internal.service}-api"
        namespace = var.app.namespace
        version   = var.ranker_internal.version
      }
    })
  ]
}