resource "helm_release" "layout_ocr_service" {
  count = var.layout_ocr.type == "google" ? 0 : 1

  depends_on = [kubernetes_namespace.eyelevel, kubernetes_config_map.layout_config_file]

  name       = "${var.layout_internal.service}-ocr"
  namespace  = var.app.namespace

  chart      = "${path.module}/../../../modules/layout/ocr/helm_chart"

  values = [
    yamlencode({
      dependencies = {
        cache = "${var.cache_internal.service}.${var.app.namespace}.svc.cluster.local"
        file  = "${var.file_internal.service}-tenant-hl.${var.app.namespace}.svc.cluster.local"
      }
      image = var.layout_internal.process.image
      securityContext = {
        runAsUser  = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.UID, 1001) : 1001
      }
      service = {
        name      = "${var.layout_internal.service}-ocr"
        namespace = var.app.namespace
        version   = var.layout_internal.version
      }
    })
  ]

  timeout = 1800
}