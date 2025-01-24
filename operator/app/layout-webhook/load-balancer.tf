resource "helm_release" "layout_webhook_api_lb" {
  depends_on = [helm_release.layout_webhook_service]

  name       = "${var.layout_webhook_internal.service}-service"
  namespace  = var.app_internal.namespace
  chart      = "${local.module_path}/scaling/load-balancer/helm_chart"

  values = [
    yamlencode({
      internal  = var.layout_webhook_resources.load_balancer.internal
      name      = "${var.layout_webhook_internal.service}-service"
      namespace = var.app_internal.namespace
      port      = var.layout_webhook_resources.load_balancer.port
      target    = var.layout_webhook_internal.service
      timeout   = 240
    })
  ]
}