resource "helm_release" "layout_ocr_service" {
  count = var.layout.ocr.type == "google" ? 0 : 1

  name       = "${var.layout_internal.service}-ocr"
  namespace  = var.app_internal.namespace

  chart      = "${local.module_path}/layout/ocr/helm_chart"

  values = [
    yamlencode({
      dependencies = {
        cache = "${local.cache_settings.addr} ${local.cache_settings.port}"
        file  = "${local.file_settings.dependency} ${local.file_settings.port}"
      }
      image = var.layout_internal.process.image
      nodeSelector    = {
        node          = var.layout_internal.nodes.ocr
      }
      securityContext = {
        runAsUser  = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.UID, 1001) : 1001
      }
      service = {
        name      = "${var.layout_internal.service}-ocr"
        namespace = var.app_internal.namespace
        version   = var.layout_internal.version
      }
    })
  ]
}