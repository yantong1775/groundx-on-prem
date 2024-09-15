resource "helm_release" "ranker_inference_service" {
  count = local.create_ranker ? 1 : 0

  depends_on = [kubernetes_namespace.eyelevel, kubernetes_config_map.ranker_config_file]

  name       = "${var.ranker_internal.service}-inference-cluster"
  namespace  = var.app.namespace

  chart      = "${path.module}/../../../modules/ranker/inference/helm_chart"

  values = [
    yamlencode({
      dependencies = {
        cache = "${var.cache_internal.service}.${var.app.namespace}.svc.cluster.local"
      }
      image = var.cluster.internet_access ? var.ranker_internal.inference.image : var.ranker_internal.inference.image_op
      securityContext = {
        runAsUser  = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.UID, 1001) : 1001
      }
      service = {
        name      = "${var.ranker_internal.service}-inference"
        namespace = var.app.namespace
        version   = var.ranker_internal.version
      }
    })
  ]

  timeout = 1800
}