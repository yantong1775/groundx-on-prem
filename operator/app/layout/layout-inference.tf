resource "helm_release" "layout_inference_service" {
  name       = "${var.layout_internal.service}-inference-cluster"
  namespace  = var.app_internal.namespace

  chart      = "${local.module_path}/layout/inference/helm_chart"

  timeout    = 600

  values = [
    yamlencode({
      dependencies    = {
        cache         = "${local.cache_settings.addr} ${local.cache_settings.port}"
        file          = "${local.file_settings.dependency} ${local.file_settings.port}"
      }
      image           = var.cluster.internet_access ? var.layout_internal.inference.image : var.layout_internal.inference.image_op
      nodeSelector    = {
        node          = var.cluster_internal.nodes.gpu_layout
      }
      replicas        = var.layout_resources.inference.replicas
      securityContext = {
        runAsUser     = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.UID, 1001) : 1001
      }
      service         = {
        name          = "${var.layout_internal.service}-inference"
        namespace     = var.app_internal.namespace
        version       = var.layout_internal.version
      }
    })
  ]
}