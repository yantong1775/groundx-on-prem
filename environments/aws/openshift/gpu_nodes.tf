resource "helm_release" "gpu_node" {
  name       = "gpu-node"
  namespace  = var.app.namespace
  chart      = "${local.module_path}/gpu-node/openshift/helm_chart"

  values = [
    yamlencode({
      ami          = "ami-0bd520c1e8206c589"
      instanceType = "g4dn.xlarge"
      minReplicas  = 1
      maxReplicas  = 10
      replicas     = 1
      name         = "gpu-node"
      namespace    = var.app.namespace
    })
  ]
}