resource "helm_release" "gpu_operator" {
  count = var.cluster.has_nvidia ? 0 : 1

  name             = var.cluster_internal.nvidia.name

  repository       = var.cluster_internal.nvidia.chart.repository
  chart            = var.cluster_internal.nvidia.chart.name
  version          = var.cluster_internal.nvidia.chart.version

  namespace        = var.cluster_internal.nvidia.namespace
  create_namespace = true
  atomic           = true
  cleanup_on_fail  = true
  reset_values     = true
  replace          = true

  set {
    name  = "driver.version"
    value = var.cluster_internal.nvidia.driver
  }
}