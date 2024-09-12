resource "helm_release" "queue_service" {
  count = local.create_queue ? 1 : 0

  depends_on = [helm_release.groundx_service]

  name       = "${var.queue_service}-cluster"
  namespace  = var.namespace
  chart      = "${path.module}/../../../modules/queue/helm_chart"

  values = [
    yamlencode({
      image = {
        pull       = var.queue_image_pull
        repository = var.queue_image_url
        tag        = var.queue_image_tag
      }
      securityContext = {
        runAsUser  = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.UID, 1001) : 1001
        runAsGroup = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.GID, 1001) : 1001
        fsGroup    = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.GID, 1001) : 1001
      }
      service = {
        name      = var.queue_service
        namespace = var.namespace
        version   = var.queue_version
      }
    })
  ]

  timeout = 1800
}