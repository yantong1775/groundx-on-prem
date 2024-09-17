resource "helm_release" "layout_ocr_service" {
  name       = "${var.layout_internal.service}-ocr"
  namespace  = var.app.namespace

  chart      = "${local.module_path}/layout/ocr/helm_chart"

  values = [
    yamlencode({
      dependencies = {
        cache = "${var.cache_internal.service}.${var.app.namespace}.svc.cluster.local"
        file  = "${var.file_internal.service}-tenant-hl.${var.app.namespace}.svc.cluster.local"
      }
      image = var.layout_internal.process.image
      nodeSelector    = {
        node          = var.layout.nodes.ocr
      }
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
}