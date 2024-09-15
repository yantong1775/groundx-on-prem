resource "helm_release" "strimzi_operator" {
  count = local.create_kafka ? 1 : 0

  depends_on = [kubernetes_namespace.eyelevel]

  name       = "${var.stream_internal.service}-operator"
  namespace  = var.app.namespace
  chart      = var.stream_internal.chart.url
  version    = var.stream_internal.chart.version

  values = [
    yamlencode({
      replicas = var.stream.operator.replicas
    })
  ]
}

resource "helm_release" "kafka_cluster" {
  count = local.create_kafka ? 1 : 0

  depends_on = [helm_release.strimzi_operator]

  name       = "${var.stream_internal.service}-cluster"
  namespace  = var.app.namespace
  chart      = "${path.module}/../../../modules/kafka/helm_chart"

  values = [
    yamlencode({
      resources = var.stream.resources
      service = {
        partitions      = var.stream.partitions
        port            = var.stream_internal.port
        replicas        = var.stream.service.replicas
        retention_bytes = var.stream.retention_bytes
        segment_bytes   = var.stream.segment_bytes
        storage    = {
          size = var.stream.service.storage
        }
        version = var.stream_internal.version
      }
      zookeeper = {
        replicas = var.stream.zookeeper.replicas
        storage  = {
          size = var.stream.zookeeper.storage
        }
      }
    })
  ]

  timeout = 600
}