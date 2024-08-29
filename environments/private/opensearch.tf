resource "helm_release" "opensearch_operator" {
  count = local.create_opensearch ? 1 : 0

  depends_on = [kubernetes_namespace.eyelevel]

  name       = "${var.search_service}-operator"
  namespace  = var.namespace
  chart      = var.search_chart_name
  repository = var.search_chart_url
  version    = var.search_chart_version

  values = [
    yamlencode({
      clusterName = "${var.search_service}-cluster"
      extraEnvs = [
        {
          name  = "OPENSEARCH_INITIAL_ADMIN_PASSWORD"
          value = var.search_root_password
        },
      ]
      global = {
        dockerRegistry = var.search_image_url
      }
      image = {
        repository = var.search_image_repository
        tag = var.search_image_tag
      }
      majorVersion = var.search_version
      nodeGroup   = "master"
      persistence = {
        enabled = true
        enableInitChown = false
        size = var.search_pv_size
      }
      podSecurityContext = {
        runAsUser  = tonumber(data.external.get_uid_gid.result.UID)
        fsGroup    = tonumber(data.external.get_uid_gid.result.GID)
      }
      replicas = var.search_replicas
      resources = {
        requests = {
          cpu    = var.search_cpu_requests
          memory = var.search_memory_requests
        }
      }
      securityContext = {
        runAsUser    = tonumber(data.external.get_uid_gid.result.UID)
        runAsNonRoot = true
      }
      singleNode = var.search_replicas == 1
    })
  ]
}