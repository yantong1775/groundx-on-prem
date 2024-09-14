resource "helm_release" "layout_ocr_service" {
  count = var.layout_ocr_handler.type == "google" ? 0 : 1

  depends_on = [kubernetes_namespace.eyelevel, kubernetes_config_map.layout_config_file]

  name       = "${var.layout_service.name}-ocr"
  namespace  = var.namespace

  chart      = "${path.module}/../../../modules/layout/ocr/helm_chart"

  values = [
    yamlencode({
      dependencies = {
        cache = "${var.cache_service}.${var.namespace}.svc.cluster.local"
      }
      image = var.layout_process_image
      securityContext = {
        runAsUser  = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.UID, 1001) : 1001
      }
      service = {
        name      = "${var.layout_service.name}-ocr"
        namespace = var.namespace
        version   = var.layout_service.version
      }
    })
  ]

  timeout = 1800
}