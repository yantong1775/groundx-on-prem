resource "helm_release" "groundx_lb" {
  count = local.is_openshift ? 0 : 1

  depends_on = [helm_release.groundx_service]

  name       = "${var.groundx_internal.service}-cluster-lb"
  namespace  = var.app.namespace
  chart      = "${path.module}/../../../modules/load-balancer/load-balancer/helm_chart"

  values = [
    yamlencode({
      name      = "${var.groundx_internal.service}-cluster-lb"
      namespace = var.app.namespace
      port      = var.groundx.load_balancer.port
      target    = "${var.groundx_internal.service}"
    })
  ]
}