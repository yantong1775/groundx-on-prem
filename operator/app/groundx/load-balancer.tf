resource "helm_release" "groundx_lb" {
  count = local.is_openshift ? 0 : 1

  depends_on = [helm_release.groundx_service]

  name       = "${var.groundx_internal.service}-cluster-lb"
  namespace  = var.app_internal.namespace
  chart      = "${local.module_path}/load-balancer/load-balancer/helm_chart"

  values = [
    yamlencode({
      name      = "${var.groundx_internal.service}-cluster-lb"
      namespace = var.app_internal.namespace
      port      = var.groundx.load_balancer.port
      target    = "${var.groundx_internal.service}"
    })
  ]
}

resource "helm_release" "groundx_route" {
  count = local.is_openshift ? 1 : 0

  depends_on = [helm_release.groundx_service]

  name       = "${var.groundx_internal.service}-cluster-route"
  namespace  = var.app_internal.namespace
  chart      = "${local.module_path}/load-balancer/route/helm_chart"

  values = [
    yamlencode({
      name      = "${var.groundx_internal.service}-cluster-route"
      namespace = var.app_internal.namespace
      target    = "${var.groundx_internal.service}"
    })
  ]
}