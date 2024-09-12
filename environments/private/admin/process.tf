resource "helm_release" "process_service" {
  count = local.create_process ? 1 : 0

  depends_on = [helm_release.groundx_service]

  name       = "${var.process_service}-cluster"
  namespace  = var.namespace
  chart      = "${path.module}/../../../modules/process/helm_chart"

  values = [
    yamlencode({
      image = {
        pull       = var.process_image_pull
        repository = var.process_image_url
        tag        = var.process_image_tag
      }
      securityContext = {
        runAsUser  = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.UID, 1001) : 1001
        runAsGroup = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.GID, 1001) : 1001
        fsGroup    = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.GID, 1001) : 1001
      }
      service = {
        name      = var.process_service
        namespace = var.namespace
        version   = var.process_version
      }
    })
  ]

  timeout = 1800
}