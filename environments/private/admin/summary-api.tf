resource "helm_release" "summary_api_service" {
  count = local.create_summary ? 1 : 0

  depends_on = [kubernetes_namespace.eyelevel, kubernetes_config_map.summary_config_file]

  name       = "${var.summary_service}-api-cluster"
  namespace  = var.namespace

  chart      = "${path.module}/../../../modules/summary/api/helm_chart"

  values = [
    yamlencode({
      dependencies = {
        cache = "${var.cache_service}.${var.namespace}.svc.cluster.local"
      }
      image = {
        pull       = var.summary_api_image_pull
        repository = var.summary_api_image_url
        tag        = var.summary_api_image_tag
      }
      securityContext = {
        runAsUser  = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.UID, 1001) : 1001
      }
      service = {
        name      = "${var.summary_service}-api"
        namespace = var.namespace
        version   = var.summary_version
      }
    })
  ]

  timeout = 600
}