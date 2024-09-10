resource "helm_release" "groundx_service" {
  count = local.create_groundx ? 1 : 0

  depends_on = [kubernetes_config_map.cashbot_config_file, kubernetes_namespace.eyelevel]

  name       = "${var.groundx_service}-cluster"
  namespace  = var.namespace
  chart      = "${path.module}/../../../modules/groundx/helm_chart"

  values = [
    yamlencode({
      dependencies = {
        cache    = "${var.cache_service}.${var.namespace}.svc.cluster.local"
        database = "${var.db_service}-cluster-pxc-db-haproxy.${var.namespace}.svc.cluster.local"
        file     = "${var.file_service}-tenant-hl.${var.namespace}.svc.cluster.local"
        search   = "${var.search_service}-cluster-master.${var.namespace}.svc.cluster.local"
        stream   = "${var.stream_service}-cluster-cluster-kafka-bootstrap.${var.namespace}.svc.cluster.local"
      }
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

  timeout = 600
}