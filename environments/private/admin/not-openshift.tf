resource "helm_release" "groundx_lb" {
  count = local.is_openshift ? 0 : 1

  depends_on = [helm_release.groundx_service]

  name       = "${var.groundx_service}-cluster-lb"
  namespace  = var.namespace
  chart      = "${path.module}/../../../modules/load-balancer/load-balancer/helm_chart"

  values = [
    yamlencode({
      name      = "${var.groundx_service}-cluster-lb"
      namespace = var.namespace
      port      = var.groundx_lb_port
      target    = "${var.groundx_service}"
    })
  ]
}