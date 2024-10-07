resource "helm_release" "summary_inference_service" {
  count = local.create_summary ? 1 : 0

  name       = "${var.summary_internal.service}-inference-cluster"
  namespace  = var.app.namespace

  chart      = "${local.module_path}/summary/inference/helm_chart"

  timeout    = 600

  values = [
    yamlencode({
      dependencies    = {
        cache = "${local.cache_settings.addr} ${local.cache_settings.port}"
      }
      gpuMemory       = var.summary_resources.inference.gpuMemory
      image           = var.cluster.internet_access ? var.summary_internal.inference.image : var.summary_internal.inference.image_op
      nodeSelector = {
        node = var.summary_internal.nodes.inference
      }
      replicas        = var.summary_resources.replicas
      resources       = var.summary_resources.resources
      securityContext = {
        runAsUser     = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.UID, 1001) : 1001
      }
      service = {
        name          = "${var.summary_internal.service}-inference"
        namespace     = var.app.namespace
        version       = var.summary_internal.version
      }
    })
  ]
}