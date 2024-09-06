resource "helm_release" "strimzi_operator" {
  count = local.create_kafka ? 1 : 0

  depends_on = [kubernetes_namespace.eyelevel]

  name       = "${var.stream_service}-operator"
  namespace  = var.namespace
  chart      = var.stream_chart
  version    = var.stream_chart_version

  values = [
    yamlencode({
      replicas = var.stream_replicas_operator
    })
  ]
}

resource "helm_release" "kafka_cluster" {
  count = local.create_kafka ? 1 : 0

  depends_on = [helm_release.strimzi_operator]

  name       = "${var.stream_service}-cluster"
  namespace  = var.namespace
  chart      = "${path.module}/../../../modules/kafka/helm_chart"

  values = [
    yamlencode({
      resources = {
        requests = {
          memory = var.stream_memory_requests
          cpu    = var.stream_cpu_requests
        }
        limits = {
          memory = var.stream_memory_limits
          cpu    = var.stream_cpu_limits
        }
      },
      service = {
        port      = var.stream_port
        replicas  = var.stream_replicas_service
        storage   = {
          size = var.stream_storage_service
        }
        version   = var.stream_version
      },
      zookeeper = {
        replicas = var.stream_replicas_zookeeper
        storage  = {
          size = var.stream_storage_zookeeper
        }
      }
    })
  ]
}