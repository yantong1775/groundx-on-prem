resource "helm_release" "strimzi_operator" {
  count = local.create_stream ? 1 : 0

  name       = "${var.stream_internal.service}-operator"
  namespace  = var.app.namespace
  chart      = var.stream_internal.chart.url
  version    = var.stream_internal.chart.version

  values = [
    yamlencode({
      nodeSelector = {
        node = var.stream_internal.node
      }
      replicas = var.stream_resources.operator.replicas
    })
  ]
}

resource "helm_release" "kafka_cluster" {
  count = local.create_stream ? 1 : 0

  depends_on = [helm_release.strimzi_operator]

  name       = "${var.stream_internal.service}-cluster"
  namespace  = var.app.namespace
  chart      = "${local.module_path}/kafka/helm_chart"

  values = [
    yamlencode({
      nodeSelector = {
        node = var.stream_internal.node
      }
      resources = var.stream_resources.resources
      service = {
        nodeSelector = {
          node = var.stream_internal.node
        }
        partitions      = var.stream_resources.partitions
        port            = var.stream_internal.port
        replicas        = var.stream_resources.service.replicas
        retention_bytes = var.stream_resources.retention_bytes
        segment_bytes   = var.stream_resources.segment_bytes
        storage    = {
          size = var.stream_resources.service.storage
        }
        version = var.stream_internal.version
      }
      zookeeper = {
        nodeSelector = {
          node = var.stream_internal.node
        }
        replicas = var.stream_resources.zookeeper.replicas
        storage  = {
          size = var.stream_resources.zookeeper.storage
        }
      }
    })
  ]
}