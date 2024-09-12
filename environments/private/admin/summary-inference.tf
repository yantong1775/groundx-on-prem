resource "helm_release" "summary_inference_service" {
  count = local.create_summary ? 1 : 0

  depends_on = [kubernetes_namespace.eyelevel, kubernetes_config_map.summary_config_file]

  name       = "${var.summary_service}-inference-cluster"
  namespace  = var.namespace

  chart      = "${path.module}/../../../modules/summary/inference/helm_chart"

  values = [
    yamlencode({
      dependencies = {
        cache = "${var.cache_service}.${var.namespace}.svc.cluster.local"
      }
      image = {
        pull       = var.summary_inference_image_pull
        repository = var.internet_access ? var.summary_inference_image_url : var.summary_inference_image_url_no_internet
        tag        = var.summary_inference_image_tag
      }
      securityContext = {
        runAsUser  = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.UID, 1001) : 1001
      }
      service = {
        name      = "${var.summary_service}-inference"
        namespace = var.namespace
        version   = var.summary_version
      }
    })
  ]

  timeout = 1800
}