resource "helm_release" "layout_webhook_service" {
  count = local.create_layout_webhook ? 1 : 0

  depends_on = [helm_release.groundx_service]

  name       = "${var.layout_webhook_service}-cluster"
  namespace  = var.namespace
  chart      = "${path.module}/../../../modules/layout-webhook/helm_chart"

  values = [
    yamlencode({
      image = {
        pull       = var.layout_webhook_image_pull
        repository = var.layout_webhook_image_url
        tag        = var.layout_webhook_image_tag
      }
      securityContext = {
        runAsUser  = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.UID, 1001) : 1001
        runAsGroup = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.GID, 1001) : 1001
        fsGroup    = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.GID, 1001) : 1001
      }
      service = {
        name      = var.layout_webhook_service
        namespace = var.namespace
        version   = var.layout_webhook_version
      }
    })
  ]

  timeout = 1800
}