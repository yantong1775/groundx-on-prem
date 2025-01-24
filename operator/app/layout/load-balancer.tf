resource "helm_release" "layout_api_lb" {
  depends_on = [helm_release.layout_api_service]

  name       = "${var.layout_internal.service}-service"
  namespace  = var.app_internal.namespace
  chart      = "${local.module_path}/scaling/load-balancer/helm_chart"

  values = [
    yamlencode({
      internal  = var.layout_resources.load_balancer.internal
      name      = "${var.layout_internal.service}-service"
      namespace = var.app_internal.namespace
      port      = var.layout_resources.load_balancer.port
      target    = "${var.layout_internal.service}-api"
      timeout   = 240
    })
  ]
}