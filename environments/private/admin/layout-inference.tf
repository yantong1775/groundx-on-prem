resource "helm_release" "layout_inference_service" {
  count = local.create_layout ? 1 : 0

  depends_on = [kubernetes_namespace.eyelevel, kubernetes_config_map.layout_config_file]

  name       = "${var.layout_internal.service}-inference-cluster"
  namespace  = var.app.namespace

  chart      = "${path.module}/../../../modules/layout/inference/helm_chart"

  values = [
    yamlencode({
      dependencies = {
        cache = "${var.cache_internal.service}.${var.app.namespace}.svc.cluster.local"
        file  = "${var.file_internal.service}-tenant-hl.${var.app.namespace}.svc.cluster.local"
      }
      image = var.cluster.internet_access ? var.layout_internal.inference.image : var.layout_internal.inference.image_op
      securityContext = {
        runAsUser  = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.UID, 1001) : 1001
      }
      service = {
        name      = "${var.layout_internal.service}-inference"
        namespace = var.app.namespace
        version   = var.layout_internal.version
      }
    })
  ]

  timeout = 1800
}