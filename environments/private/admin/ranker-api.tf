resource "helm_release" "ranker_api_service" {
  count = local.create_ranker ? 1 : 0

  depends_on = [kubernetes_namespace.eyelevel, kubernetes_config_map.ranker_config_file]

  name       = "${var.ranker_service}-api-cluster"
  namespace  = var.namespace

  chart      = "${path.module}/../../../modules/ranker/api/helm_chart"

  values = [
    yamlencode({
      dependencies = {
        cache = "${var.cache_service}.${var.namespace}.svc.cluster.local"
      }
      image = {
        pull       = var.ranker_api_image_pull
        repository = var.ranker_api_image_url
        tag        = var.ranker_api_image_tag
      }
      securityContext = {
        runAsUser  = data.external.get_uid_gid.result.UID
        runAsGroup = data.external.get_uid_gid.result.GID
        fsGroup    = data.external.get_uid_gid.result.GID
      }
      service = {
        name      = "${var.ranker_service}-api"
        namespace = var.namespace
        version   = var.ranker_version
      }
    })
  ]

  timeout = 600
}