resource "helm_release" "ranker_inference_service" {
  count = local.create_ranker ? 1 : 0

  depends_on = [kubernetes_namespace.eyelevel, kubernetes_config_map.ranker_config_file]

  name       = "${var.ranker_service}-inference-cluster"
  namespace  = var.namespace

  chart      = "${path.module}/../../../modules/ranker/inference/helm_chart"

  values = [
    yamlencode({
      dependencies = {
        cache = "${var.cache_service}.${var.namespace}.svc.cluster.local"
      }
      image = {
        pull       = var.ranker_inference_image_pull
        repository = var.ranker_inference_image_url
        tag        = var.ranker_inference_image_tag
      }
      securityContext = {
        runAsUser  = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.UID, 1001) : 1001
      }
      service = {
        name      = "${var.ranker_service}-inference"
        namespace = var.namespace
        version   = var.ranker_version
      }
    })
  ]

  timeout = 1800
}