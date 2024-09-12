resource "helm_release" "summary_client_service" {
  count = local.create_summary_client ? 1 : 0

  depends_on = [helm_release.groundx_service]

  name       = "${var.summary_client_service}-cluster"
  namespace  = var.namespace
  chart      = "${path.module}/../../../modules/summary-client/helm_chart"

  values = [
    yamlencode({
      image = {
        pull       = var.summary_client_image_pull
        repository = var.summary_client_image_url
        tag        = var.summary_client_image_tag
      }
      securityContext = {
        runAsUser  = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.UID, 1001) : 1001
        runAsGroup = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.GID, 1001) : 1001
        fsGroup    = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.GID, 1001) : 1001
      }
      service = {
        name      = var.summary_client_service
        namespace = var.namespace
        version   = var.summary_client_version
      }
    })
  ]

  timeout = 1800
}