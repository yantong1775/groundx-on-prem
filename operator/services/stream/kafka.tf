resource "helm_release" "strimzi_operator" {
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
  depends_on = [helm_release.strimzi_operator]

  name       = "${var.stream_internal.service}-cluster"
  namespace  = var.app.namespace
  chart      = "${local.module_path}/kafka/helm_chart"

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
}