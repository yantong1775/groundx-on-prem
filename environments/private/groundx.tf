resource "helm_release" "groundx_service" {
  count = local.create_groundx ? 1 : 0

  depends_on = [kubernetes_namespace.eyelevel, kubernetes_config_map.cashbot_config_file]

  name       = "${var.groundx_service}-cluster"
  namespace  = var.namespace
  chart      = "${path.module}/../../modules/groundx/helm_chart"

  values = [
    yamlencode({
      image = {
        pull       = var.groundx_image_pull
        repository = var.groundx_image_url
        tag        = var.groundx_image_tag
      }
      securityContext = {
        runAsUser  = data.external.get_uid_gid.result.UID
        runAsGroup = data.external.get_uid_gid.result.GID
        fsGroup    = data.external.get_uid_gid.result.GID
      }
      service = {
        name      = var.groundx_service
        namespace = var.namespace
        version   = var.groundx_version
      }
    })
  ]
}