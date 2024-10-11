resource "helm_release" "ranker_inference_service" {
  name       = "${var.ranker_internal.service}-inference-cluster"
  namespace  = var.app_internal.namespace

  chart      = "${local.module_path}/ranker/inference/helm_chart"

  timeout    = 600

  values = [
    yamlencode({
      dependencies    = {
        cache = "${local.cache_settings.addr} ${local.cache_settings.port}"
      }
      gpuMemory       = var.ranker_resources.inference.gpuMemory
      image           = var.cluster.internet_access ? var.ranker_internal.inference.image : var.ranker_internal.inference.image_op
      nodeSelector = {
        node = var.ranker_internal.nodes.inference
      }
      replicas        = var.ranker_resources.replicas
      resources       = var.ranker_resources.resources
      securityContext = {
        runAsUser     = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.UID, 1001) : 1001
      }
      service = {
        name          = "${var.ranker_internal.service}-inference"
        namespace     = var.app_internal.namespace
        version       = var.ranker_internal.version
      }
    })
  ]
}