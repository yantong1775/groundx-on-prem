resource "helm_release" "layout_process_service" {
  name       = "${var.layout_internal.service}-process"
  namespace  = var.app_internal.namespace

  chart      = "${local.module_path}/layout/process/helm_chart"

  values = [
    yamlencode({
      dependencies = {
        cache = "${local.cache_settings.addr} ${local.cache_settings.port}"
        file  = "${local.file_settings.dependency} ${local.file_settings.port}"
      }
      image = var.layout_internal.process.image
      nodeSelector    = {
        node          = var.cluster_internal.nodes.cpu_memory
      }
      queues = (
        var.layout.ocr.type == "google" ?
          "process_queue,ocr_queue,map_queue,save_queue" :
          "process_queue,map_queue,save_queue"
      )
      securityContext = {
        runAsUser  = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.UID, 1001) : 1001
      }
      service = {
        name      = "${var.layout_internal.service}-process"
        namespace = var.app_internal.namespace
        version   = var.layout_internal.version
      }
    })
  ]
}